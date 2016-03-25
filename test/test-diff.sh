${1} ${2} tradkana test/ModernKanaNewKanji.ok > test/TradKanaNewKanji.out
if diff -q test/TradKanaNewKanji.out test/TradKanaNewKanji.ok > /dev/null; then
    echo "  tradkana test:   \033[3#2mOK\033[0m"
else
    echo "  tradkana test:   \033[3#1mNG\033[0m"
fi

${1} ${2} modernkana test/TradKanaNewKanji.ok > test/ModernKanaNewKanji.out
if diff -q test/ModernKanaNewKanji.out test/ModernKanaNewKanji.ok > /dev/null; then
    echo "  modernkana test: \033[3#2mOK\033[0m"
else
    echo "  modernkana test: \033[3#1mNG\033[0m"
fi

${1} ${2} oldkanji test/ModernKanaNewKanji.ok > test/ModernKanaOldKanji.out
if diff -q test/ModernKanaOldKanji.out test/ModernKanaOldKanji.ok > /dev/null; then
    echo "  oldkanji test:   \033[3#2mOK\033[0m"
else
    echo "  oldkanji test:   \033[3#1mNG\033[0m"
fi

${1} ${2} newkanji test/ModernKanaOldKanji.ok > test/ModernKanaNewKanji.out
if diff -q test/ModernKanaNewKanji.out test/ModernKanaNewKanji.ok > /dev/null; then
    echo "  newkanji test:   \033[3#2mOK\033[0m"
else
    echo "  newkanji test:   \033[3#1mNG\033[0m"
fi
