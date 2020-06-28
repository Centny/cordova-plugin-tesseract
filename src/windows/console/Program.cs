using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace console
{
    class Program
    {
        static void Main(string[] args)
        {
            string res = Tesseract.bootstrap("..\\..\\..\\..\\..\\..\\..\\deps\\tessdata", "chi_sim");
            if ("ok" != res)
            {
                throw new Exception(res);
            }
            string text;
            string[] parts;
            //png
            byte[] png = File.ReadAllBytes("..\\..\\..\\..\\..\\..\\..\\deps\\tessdata\\chi_sim.png");
            text = Tesseract.recognize(Convert.ToBase64String(png));
            parts = text.Split(new char[1] { ',' }, 2);
            if (parts[0] != "0")
            {
                throw new Exception(parts[1]);
            }
            Console.WriteLine(parts[1]);
            text = Tesseract.recognize(Convert.ToBase64String(png), 10, 10, 1000, 400);
            parts = text.Split(new char[1] { ',' }, 2);
            if (parts[0] != "0")
            {
                throw new Exception(parts[1]);
            }
            Console.WriteLine(parts[1]);
            //jpg
            byte[] jpg = File.ReadAllBytes("..\\..\\..\\..\\..\\..\\..\\deps\\tessdata\\chi_sim.jpg");
            text = Tesseract.recognize(Convert.ToBase64String(jpg));
            parts = text.Split(new char[1] { ',' }, 2);
            if (parts[0] != "0")
            {
                throw new Exception(parts[1]);
            }
            Console.WriteLine(parts[1]);
            text = Tesseract.recognize(Convert.ToBase64String(jpg), 10, 10, 1000, 400);
            parts = text.Split(new char[1] { ',' }, 2);
            if (parts[0] != "0")
            {
                throw new Exception(parts[1]);
            }
            Console.WriteLine(parts[1]);
            text = Tesseract.recognize(Convert.ToBase64String(jpg), 1000, 10, 1000, 400);
            parts = text.Split(new char[1] { ',' }, 2);
            if (parts[0] == "0")
            {
                throw new Exception(parts[1]);
            }
            Console.WriteLine(parts[1]);
            Tesseract.shutdown();
        }
    }
}
