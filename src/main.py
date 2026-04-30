import os, webview
os.environ['WEBVIEW2_BROWSER_EXECUTABLE_FOLDER'] = "C:\ProgramData\VoltPlus\webview"

#start window
window = webview.create_window('VoltEnhanced', 'https://example.com')
webview.start(storage_path=None, private_mode=False)
