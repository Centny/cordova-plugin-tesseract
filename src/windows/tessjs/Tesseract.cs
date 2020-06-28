using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Storage;

namespace tessjs
{
    /// <summary>
    /// Tesseract will provider the uwp binder to tess.
    /// </summary>
    public sealed class Tesseract
    {
        static private IntPtr shared = IntPtr.Zero;
        [DllImport("tessc.dll", CallingConvention = CallingConvention.Cdecl)]
        static private extern IntPtr tess_bootstrap(string datapath, string language);
        [DllImport("tessc.dll", CallingConvention = CallingConvention.Cdecl)]
        static private extern void tess_shutdown(IntPtr tess);
        [DllImport("tessc.dll", CallingConvention = CallingConvention.Cdecl)]
        static private extern int tess_recognize(IntPtr tess, byte[] buffer, byte[] image, int imageSize, int x, int y, int w, int h);

        static byte[] BUFFER = new byte[1024 * 1024];

        public static IAsyncOperation<string> shutdown()
        {
            return Task.Run(() =>
            {
                if (shared == IntPtr.Zero)
                {
                    return "not bootstrap";
                }
                tess_shutdown(shared);
                return "";
            }).AsAsyncOperation();
        }

        public static IAsyncOperation<string> bootstrap()
        {
            return Task.Run(async () =>
            {
                try
                {
                    if (shared != IntPtr.Zero)
                    {
                        return "already bootstrap";
                    }
                    string datapath = "", language = "";
                    StorageFolder tessdata;
                    try
                    {
                        tessdata = await Windows.ApplicationModel.Package.Current.InstalledLocation.GetFolderAsync("tessdata");
                    }
                    catch (Exception)
                    {
                        tessdata = await Windows.ApplicationModel.Package.Current.InstalledLocation.GetFolderAsync("Assets");
                    }
                    datapath = tessdata.Path;
                    var items = await tessdata.GetItemsAsync();
                    foreach (var item in items)
                    {
                        if (Path.GetExtension(item.Path) != ".traineddata")
                        {
                            continue;
                        }
                        if (language.Length > 0)
                        {
                            language += "+";
                        }
                        language += Path.GetFileNameWithoutExtension(item.Path);
                    }
                    if (language.Length < 1)
                    {
                        return ".traineddata not exists on " + tessdata;
                    }
                    return await bootstrap(datapath, language);
                }
                catch (Exception e)
                {
                    return e.Message;
                }
            }).AsAsyncOperation();
        }

        public static IAsyncOperation<string> bootstrap(string datapath, string language)
        {
            return Task.Run(() =>
            {
                if (shared != IntPtr.Zero)
                {
                    return "already bootstrap";
                }
                shared = tess_bootstrap(datapath, language);
                if (shared == IntPtr.Zero)
                {
                    return "bootstrap fail";
                }
                return "ok";
            }).AsAsyncOperation();
        }

        public static IAsyncOperation<string> recognize(string image)
        {
            return recognize(image, 0, 0, 0, 0);

        }

        public static IAsyncOperation<string> recognize(string image, int x, int y, int w, int h)
        {
            return Task.Run(() =>
            {
                string result;
                try
                {
                    if (shared == IntPtr.Zero)
                    {
                        throw new Exception("not bootstrap");
                    }
                    byte[] data = Convert.FromBase64String(image);
                    IntPtr text = IntPtr.Zero;
                    int len = tess_recognize(shared, BUFFER, data, data.Length, x, y, w, h);
                    if (len > 0)
                    {
                        result = "0," + Encoding.UTF8.GetString(BUFFER, 0, len);
                    }
                    else
                    {
                        switch (len)
                        {
                            case -1:
                                result = len + ",text not found";
                                break;
                            case -2:
                                result = len + ",wrap image fail";
                                break;
                            case -3:
                                result = len + ",rectangle error";
                                break;
                            default:
                                result = len + ",fail";
                                break;
                        }
                    }
                }
                catch (Exception e)
                {
                    result = "9," + e.Message;
                }
                return result;
            }).AsAsyncOperation();
        }
    }
}
