/*
 * mto を C# で実装する実験
 *
 * Author: nakinor
 * Created: 2012-03-25
 * Revised: 2012-06-27
 *
 */

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
// 後から追加したもの
using System.Collections;
using System.IO;
using System.Text.RegularExpressions;


namespace MtoGW
{

    public partial class Form1 : Form
    {
        // 辞書の場所は現状の mto ディレクトリに合わせて固定している
        public static string KANA_FILE = Properties.Settings.Default.KanaDict;
        public static string KANJI_FILE = Properties.Settings.Default.KanjiDict;

        static ArrayList LIST = new ArrayList();

        public Form1()
        {
            InitializeComponent();
        }

        // 結果出力用のテキストボックス枠
        private void outputText_TextChanged(object sender, EventArgs e)
        {
            
        }

        // 入力用のテキストボックス枠
        private void inputText_TextChanged(object sender, EventArgs e)
        {

        }

        // ラベル1
        private void label1_Click(object sender, EventArgs e)
        {

        }

        // ラベル2
        private void label2_Click(object sender, EventArgs e)
        {

        }

        // 区切り線1
        private void label3_Click(object sender, EventArgs e)
        {

        }

        // 区切り線2
        private void label4_Click(object sender, EventArgs e)
        {

        }

        // 区切り線3
        private void label5_Click(object sender, EventArgs e)
        {

        }

        // 辞書を作成する
        static void CreateDictionary(string dictfile, string flag)
        {
            if (System.IO.File.Exists(dictfile))
            {
                StreamReader sr = new StreamReader(dictfile, Encoding.GetEncoding("utf-8"));
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
            else
            {
                Form2 f = new Form2();
                f.ShowDialog();
                f.Dispose();
            }
        }

        // 文字列を置換する
        static string ReplaceText(String inputString)
        {
            foreach (string[] key in LIST)
            {
                inputString = inputString.Replace(key[0], key[1]);
            }
                return inputString;
        }

        // 新かなから旧かなへ変換
        private void button1_Click(object sender, EventArgs e)
        {
            string inputString = inputText.Text;
            CreateDictionary(KANA_FILE, "car");
            String replacedText = ReplaceText(inputString);
            outputText.Clear();
            outputText.Paste(replacedText);
            LIST = new ArrayList { };
        }

        // 旧かなから新かなへ変換
        private void button2_Click(object sender, EventArgs e)
        {
            string inputString = inputText.Text;
            CreateDictionary(KANA_FILE, "cdr");
            String replacedText = ReplaceText(inputString);
            outputText.Clear();
            outputText.Paste(replacedText);
            LIST = new ArrayList { };
        }

        // 新漢字から旧漢字へ変換
        private void button3_Click(object sender, EventArgs e)
        {
            string inputString = inputText.Text;
            CreateDictionary(KANJI_FILE, "car");
            String replacedText = ReplaceText(inputString);
            outputText.Clear();
            outputText.Paste(replacedText);
            LIST = new ArrayList { };
        }

        // 旧漢字から新漢字へ変換
        private void button4_Click(object sender, EventArgs e)
        {
            string inputString = inputText.Text;
            CreateDictionary(KANJI_FILE, "cdr");
            String replacedText = ReplaceText(inputString);
            outputText.Clear();
            outputText.Paste(replacedText);
            LIST = new ArrayList { };
        }

        // 変換後のテキストを変換対象のテキストボックスへ移動
        private void button5_Click(object sender, EventArgs e)
        {
            string resultString = outputText.Text;
            inputText.Clear();
            outputText.Clear();
            inputText.Paste(resultString);
            LIST = new ArrayList { };
        }

        // 新字新かなを旧字旧かなへ変換
        private void button6_Click(object sender, EventArgs e)
        {
            string inputString = inputText.Text;
            CreateDictionary(KANA_FILE, "car");
            String replacedText = ReplaceText(inputString);
            CreateDictionary(KANJI_FILE, "car");
            replacedText = ReplaceText(inputString);
            outputText.Clear();
            outputText.Paste(replacedText);
            LIST = new ArrayList { };
        }

        // 旧字旧かなを新字新かなへ変換
        private void button7_Click(object sender, EventArgs e)
        {
            string inputString = inputText.Text;
            CreateDictionary(KANJI_FILE, "cdr");
            String replacedText = ReplaceText(inputString);
            CreateDictionary(KANA_FILE, "cdr");
            replacedText = ReplaceText(inputString);
            outputText.Clear();
            outputText.Paste(replacedText);
            LIST = new ArrayList { };
        }

        // 変換前のテキストを消去
        private void button8_Click(object sender, EventArgs e)
        {
            inputText.Clear();
        }

        // 変換結果をクリップボードにコピー
        private void button9_Click(object sender, EventArgs e)
        {
            Clipboard.SetDataObject(outputText.Text, true);
        }

        // クリップボードを変換候補にする
        private void button10_Click(object sender, EventArgs e)
        {
            IDataObject data = Clipboard.GetDataObject();

            if (data.GetDataPresent(DataFormats.Text))
            {
                inputText.Text = (string)data.GetData(DataFormats.UnicodeText);
            }
        }


        // メニューバー関係 ///////////////////////////////////////////////
        // MtoGW メニュー
        private void ToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        // aboutを表示
        private void aboutMenuToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MessageBox.Show("MtoGW (Mto GUI for Windows)\n\n文字列の簡易変換プログラム\n");
        }

        // プログラムを終了
        private void endMenuToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }


        // ファイルメニュー
        private void toolStripMenuItem1_Click(object sender, EventArgs e)
        {

        }

        // ファイルを開いてそれを変換させる
        private void openFileToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            OpenFileDialog openfile = new OpenFileDialog();
            openfile.RestoreDirectory = true;
            if (openfile.ShowDialog() == DialogResult.OK)
            {
                Stream stream;
                stream = openfile.OpenFile();
                if (stream != null)
                {
                    StreamReader sr = new StreamReader(stream, Encoding.GetEncoding("utf-8"));
                    inputText.Text = sr.ReadToEnd();
                    sr.Close();
                    stream.Close();
                }
            }
        }

        // ファイルを別名で保存
        private void saveOtherFileToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SaveFileDialog savefile = new SaveFileDialog();
            savefile.RestoreDirectory = true;

            if (savefile.ShowDialog() == DialogResult.OK)
            {
                StreamWriter sw = new StreamWriter(savefile.FileName, false, Encoding.GetEncoding("utf-8"));
                sw.Write(outputText.Text);
                sw.Close();
            }
        }

        // フォントメニュー
        private void ToolStripMenuItem3_Click(object sender, EventArgs e)
        {

        }

        // フォントパネルを表示
        private void showFontPanelToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FontDialog fontDialog = new FontDialog();
            fontDialog.Font = inputText.Font;
            float fontsize = fontDialog.Font.GetHeight();
            if (fontDialog.ShowDialog() == DialogResult.OK)
            {
                inputText.Font = fontDialog.Font;
                outputText.Font = fontDialog.Font;
            }
        }

        // フォントを小さくする
        private void smallFontToolStripMenuItem_Click(object sender, EventArgs e)
        {
            int currentFontSize = (int)inputText.Font.SizeInPoints -3;
            if (currentFontSize > 5)
            {
                FontFamily currentFontFamily = inputText.Font.FontFamily;
                FontStyle currentFontStyle = inputText.Font.Style;
                Font fMin = new Font(currentFontFamily, currentFontSize, currentFontStyle);
                inputText.Font = fMin;
                outputText.Font = fMin;
            }
            else
            {
                MessageBox.Show("もうこれ以上小さくできないっ\n");
            }
        }

        // フォントを大きくする
        private void largeFontToolStripMenuItem_Click(object sender, EventArgs e)
        {
            int currentFontSize = (int)inputText.Font.SizeInPoints + 3;
            if (currentFontSize < 100)
            {
                FontFamily currentFontFamily = inputText.Font.FontFamily;
                FontStyle currentFontStyle = inputText.Font.Style;
                Font fMax = new Font(currentFontFamily, currentFontSize, currentFontStyle);
                inputText.Font = fMax;
                outputText.Font = fMax;
            }
            else
            {
                MessageBox.Show("もうこれ以上大きくできないっ\n");
            }
        }


        // ヘルプメニュー
        private void toolStripMenuItem2_Click(object sender, EventArgs e)
        {

        }

        // ヘルプを表示する
        private void showHelpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MessageBox.Show("ないんだな、これが\n");
        }


        // 編集メニュー
        private void ToolStripMenuItem4_Click(object sender, EventArgs e)
        {

        }

        private void クリップボードから入力ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            IDataObject data = Clipboard.GetDataObject();

            if (data.GetDataPresent(DataFormats.Text))
            {
                inputText.Text = (string)data.GetData(DataFormats.UnicodeText);
            }
        }

        private void 全文をクリップボードへToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Clipboard.SetDataObject(outputText.Text, true);
        }

        private void 内容を消去ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            inputText.Clear();
        }

        private void 変換結果を入力へToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string resultString = outputText.Text;
            inputText.Clear();
            outputText.Clear();
            inputText.Paste(resultString);
            LIST = new ArrayList { };
        }

        private void 新かなを旧かなへ変換ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string inputString = inputText.Text;
            CreateDictionary(KANA_FILE, "car");
            String replacedText = ReplaceText(inputString);
            outputText.Clear();
            outputText.Paste(replacedText);
            LIST = new ArrayList { };
        }

        private void 旧仮名を新かなへ変換ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string inputString = inputText.Text;
            CreateDictionary(KANA_FILE, "cdr");
            String replacedText = ReplaceText(inputString);
            outputText.Clear();
            outputText.Paste(replacedText);
            LIST = new ArrayList { };
        }

        private void 新漢字を旧漢字へ変換ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string inputString = inputText.Text;
            CreateDictionary(KANJI_FILE, "car");
            String replacedText = ReplaceText(inputString);
            outputText.Clear();
            outputText.Paste(replacedText);
            LIST = new ArrayList { };
        }

        private void 旧漢字を新漢字へ変換ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string inputString = inputText.Text;
            CreateDictionary(KANJI_FILE, "cdr");
            String replacedText = ReplaceText(inputString);
            outputText.Clear();
            outputText.Paste(replacedText);
            LIST = new ArrayList { };
        }


        private void tableLayoutPanel1_Paint_(object sender, PaintEventArgs e)
        {

        }

        private void tableLayoutPanel2_Paint(object sender, PaintEventArgs e)
        {

        }

        private void tableLayoutPanel3_Paint(object sender, PaintEventArgs e)
        {

        }

        private void menuStrip1_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {

        }

        private void 環境設定ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Form2 f = new Form2();
            f.ShowDialog(this);
            f.Dispose();
        }

    }
}
