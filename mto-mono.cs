/*
 * mto を C# で実装する実験 (CUI版)
 * MacOSX 上の mono で動くように
 *
 * Author: nakinor
 * Created: 2012-03-23
 * Revised: 2016-01-28
 *
 */

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace mtocw
{
  class Program
  {
    // 辞書の場所は環境変数から取得する
    // 注意点は Path.Combine を使うと下記の場合、path に '/' が付加される点
    static string path = System.Environment.GetEnvironmentVariable("MTODIC");
    static string KANA_FILE = Path.Combine(path, "kana-jisyo");
    static string KANJI_FILE = Path.Combine(path, "kanji-jisyo");
    static ArrayList LIST = new ArrayList();

    static void Main(string[] args)
    {
      if (args.Length == 2)
        {
          string opt = args[0];
          string ifile = args[1];
          NaviReplaceFile(opt, ifile);
        }
      else if (args.Length == 1)
        {
          string opt = args[0];
          TextReader istdin = Console.In;
          NaviReplaceStdin(opt, istdin);
          return;
        }
      else
        {
          PrintUsage();
        }
    }

    // 辞書を作成する
    static void CreateDictionary(string dictfile, string flag)
    {
      StreamReader sr =
        new StreamReader(dictfile, Encoding.GetEncoding("utf-8"));
      string line;
      Regex reg1 = new Regex("^;.*|^$");
      Regex reg2 = new Regex("\\s+;.*");

      while ((line = sr.ReadLine()) != null)
        {
          Match m = reg1.Match(line);
          if (m.Success == false)
            {
              string line2 = reg2.Replace(line, "");
              string[] pair = line2.Split(' ', '/', '\n');
              string[] pairs = new string[2];
              if (flag == "car")
                {
                  pairs[0] = pair[0];
                  pairs[1] = pair[2];
                }
              else
                {
                  pairs[0] = pair[2];
                  pairs[1] = pair[0];
                }
              LIST.Add(pairs);
            }
        }
      sr.Close();
    }

    // 指定されたファイルの文字列を置換する
    static void ReplaceTextInFile(string inputfile)
    {
      try
        {
          StreamReader sr =
            new StreamReader(inputfile, Encoding.GetEncoding("utf-8"));
          string line;
          while ((line = sr.ReadLine()) != null)
            {
              foreach (string[] key in LIST)
                {
                  line = line.Replace(key[0], key[1]);
                }
              Console.WriteLine(line);
            }
          sr.Close();
        }
      catch (System.IO.FileNotFoundException)
        {
          Console.WriteLine("ファイル名が間違ってない？");
          return;
        }
    }

    // 標準入力からの文字列を置換する
    static void ReplaceTextInStdin(TextReader inputstring)
    {
      string line;
      while ((line = inputstring.ReadLine()) != null)
        {
          foreach (string[] key in LIST)
            {
              line = line.Replace(key[0], key[1]);
            }
          Console.WriteLine(line);
        }
    }

    // Usage を表示する
    static void PrintUsage()
    {
      string arg1 = Environment.GetCommandLineArgs()[0];
      int lastEl = arg1.Split('/').Length;
      string cmdname = arg1.Split('/')[lastEl -1];

      Console.WriteLine("Usage: mono {0} options filename", cmdname);
      Console.WriteLine("options:");
      Console.WriteLine("  tradkana");
      Console.WriteLine("  modernkana");
      Console.WriteLine("  oldkanji");
      Console.WriteLine("  newkanji");
    }

    // 分岐処理(ファイル変換用)
    static void NaviReplaceFile(string opt, string ifile)
    {
      switch (opt)
        {
        case "tradkana":
          CreateDictionary(KANA_FILE, "car");
          ReplaceTextInFile(ifile);
          break;

        case "modernkana":
          CreateDictionary(KANA_FILE, "cdr");
          ReplaceTextInFile(ifile);
          break;

        case "oldkanji":
          CreateDictionary(KANJI_FILE, "car");
          ReplaceTextInFile(ifile);
          break;

        case "newkanji":
          CreateDictionary(KANJI_FILE, "cdr");
          ReplaceTextInFile(ifile);
          break;

        default:
          Console.WriteLine("オプション間違ってない？");
          break;
        }
    }

    // 分岐処理(標準入力変換用)
    static void NaviReplaceStdin(string opt, TextReader istdin)
    {
      switch (opt)
        {
        case "tradkana":
          CreateDictionary(KANA_FILE, "car");
          ReplaceTextInStdin(istdin);
          break;

        case "modernkana":
          CreateDictionary(KANA_FILE, "cdr");
          ReplaceTextInStdin(istdin);
          break;

        case "oldkanji":
          CreateDictionary(KANJI_FILE, "car");
          ReplaceTextInStdin(istdin);
          break;

        case "newkanji":
          CreateDictionary(KANJI_FILE, "cdr");
          ReplaceTextInStdin(istdin);
          break;

        default:
          Console.WriteLine("オプション間違ってない？");
          break;
        }
    }
  }
}
