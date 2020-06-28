IF NOT EXIST %2\tessdata (
mkdir %2\tessdata
)
xcopy /s /d "%1\tessdata" "%2\tessdata"