using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace console
{
    public sealed class Tesseract
    {
        static private IntPtr shared = IntPtr.Zero;
        [DllImport("tessrawc.dll", CallingConvention = CallingConvention.Cdecl)]
        static private extern IntPtr tess_bootstrap(string datapath, string language);
        [DllImport("tessrawc.dll")]
        static private extern void tess_shutdown(IntPtr tess);
        [DllImport("tessrawc.dll", CallingConvention = CallingConvention.Cdecl)]
        static private extern int tess_recognize(IntPtr tess, byte[] buffer, byte[] image, int imageSize, int x, int y, int w, int h);

        static byte[] BUFFER = new byte[1024 * 1024];


        public static string bootstrap(string datapath, string language)
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
        }

        public static string shutdown()
        {
            if (shared != IntPtr.Zero)
            {
                return "not bootstrap";
            }
            tess_shutdown(shared);
            return "";
        }

        public static string recognize(string image)
        {
            return recognize(image, 0, 0, 0, 0);

        }
        public static string recognize(string image, int x, int y, int w, int h)
        {
            string result;
            try
            {
                if (shared == IntPtr.Zero)
                {
                    result = "8,already bootstrap";
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
        }
    }
}
