$imageUrls = @(
    @{Url='https://portal2.tmu.ac.in/images/t.jpg'; File='images/t.jpg'},
    @{Url='https://portal2.tmu.ac.in/images/rightlogo.png'; File='images/rightlogo.png'},
    @{Url='https://portal2.tmu.ac.in/images/6anipt3c.gif'; File='images/6anipt3c.gif'},
    @{Url='https://portal2.tmu.ac.in/images/TMU%20Image.jpg'; File='images/TMU_Image.jpg'},
    @{Url='https://portal2.tmu.ac.in/images/tmu-camp.jpg'; File='images/tmu-camp.jpg'},
    @{Url='https://portal2.tmu.ac.in/images/TMU1-img.jpg'; File='images/TMU1-img.jpg'},
    @{Url='https://portal2.tmu.ac.in/images/Youtube_logo.png'; File='images/Youtube_logo.png'},
    @{Url='https://portal2.tmu.ac.in/images/fb%20logo.jpg'; File='images/fb_logo.jpg'},
    @{Url='https://portal2.tmu.ac.in/images/Instagram_logo.png'; File='images/Instagram_logo.png'},
    @{Url='https://portal2.tmu.ac.in/images/x.png'; File='images/x.png'},
    @{Url='https://portal2.tmu.ac.in/images/Pinterest-logo.png'; File='images/Pinterest-logo.png'},
    @{Url='https://portal2.tmu.ac.in/images/quora%20logo.png'; File='images/quora_logo.png'},
    @{Url='https://portal2.tmu.ac.in/images/threads%20logo.png'; File='images/threads_logo.png'},
    @{Url='https://portal2.tmu.ac.in/images/WhatsApp%20logo.png'; File='images/WhatsApp_logo.png'},
    @{Url='https://portal2.tmu.ac.in/images/footer copy.jpg'; File='images/footer_copy.jpg'},
    @{Url='https://portal2.tmu.ac.in/images/login.jpg'; File='images/login.jpg'}
)

foreach($item in $imageUrls) {
    Write-Host "Downloading $($item.File)..."
    try {
        Invoke-WebRequest -Uri $item.Url -OutFile $item.File -UseBasicParsing
        Write-Host "Success: $($item.File)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed: $($item.File) - $_" -ForegroundColor Red
    }
}
