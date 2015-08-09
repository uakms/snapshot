using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace MtoGW
{
    public partial class Form2 : Form
    {
        public Form2()
        {
            InitializeComponent();
        }

        private void Form2_Load(object sender, EventArgs e)
        {
            string currentKanaDict = Properties.Settings.Default.KanaDict;
            string currentKanjiDict = Properties.Settings.Default.KanjiDict;
        }

        // キャンセルボタン
        private void button3_Click(object sender, EventArgs e)
        {
            //MessageBox.Show(Properties.Settings.Default.KanaDict
            //    + "\n" + Properties.Settings.Default.KanjiDict);
            this.Close();
        }

        // 設定ボタン
        private void button4_Click(object sender, EventArgs e)
        {
            Form1.KANA_FILE = textBox1.Text;
            Form1.KANJI_FILE = textBox2.Text;
            Properties.Settings.Default.KanaDict = textBox1.Text;
            Properties.Settings.Default.KanjiDict = textBox2.Text;
            Properties.Settings.Default.Save();
            this.Close();
        }

        // かな辞書選択ボタン
        private void button1_Click(object sender, EventArgs e)
        {
            OpenFileDialog kanafile = new OpenFileDialog();
            kanafile.RestoreDirectory = true;
            if (kanafile.ShowDialog() == DialogResult.OK)
            {
                textBox1.Text = kanafile.FileName;
            }
        }

        // 漢字辞書選択ボタン
        private void button2_Click(object sender, EventArgs e)
        {
            OpenFileDialog kanjifile = new OpenFileDialog();
            kanjifile.RestoreDirectory = true;
            if (kanjifile.ShowDialog() == DialogResult.OK)
            {
                textBox2.Text = kanjifile.FileName;
            }
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
