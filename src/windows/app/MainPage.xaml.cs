using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.ApplicationModel;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.Security.Cryptography;
using Windows.Storage;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

// The Blank Page item template is documented at https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace app
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        public MainPage()
        {
            this.InitializeComponent();
        }

        private async void Button_Click(object sender, RoutedEventArgs e)
        {
            long begin = (DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000;
            this.btn.Content = "bootstrap";
            await tessjs.Tesseract.bootstrap();
            long boot = (DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000;
            this.btn.Content = "recognizing";
            string text;
            StorageFolder asserts = await Package.Current.InstalledLocation.GetFolderAsync("Assets");
            var png = await FileIO.ReadBufferAsync(await asserts.GetFileAsync("chi_sim.png"));
            text = await tessjs.Tesseract.recognize(CryptographicBuffer.EncodeToBase64String(png));
            var jpg = await FileIO.ReadBufferAsync(await asserts.GetFileAsync("chi_sim.jpg"));
            text = await tessjs.Tesseract.recognize(CryptographicBuffer.EncodeToBase64String(jpg), 100, 10, 1000, 400);
            long end = (DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000;
            this.info.Text = String.Format("used {0}/{1} ms\n{2}\n", end - boot, end - begin, text.Split(new char[1] { ',' }, 2)[1]);
            this.btn.Content = "start";
        }
    }
}
