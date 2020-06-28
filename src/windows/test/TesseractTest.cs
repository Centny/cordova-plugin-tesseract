
using System;
using System.Diagnostics;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Windows.ApplicationModel;
using Windows.Security.Cryptography;
using Windows.Storage;

namespace test
{
    [TestClass]
    public class TesseractTest
    {
        [TestMethod]
        public void TestNormal()
        {
            Task.Run(async () =>
            {
                string result;
                result = await tessjs.Tesseract.bootstrap();
                Assert.AreEqual("ok", result);
                StorageFolder asserts = await Package.Current.InstalledLocation.GetFolderAsync("Assets");
                var buffer = await FileIO.ReadBufferAsync(await asserts.GetFileAsync("chi_sim.png"));
                var data = CryptographicBuffer.EncodeToBase64String(buffer);
                var text = await tessjs.Tesseract.recognize(data, 100, 10, 1000, 400);
                Debug.WriteLine(text);
            }).Wait();
        }
    }
}
