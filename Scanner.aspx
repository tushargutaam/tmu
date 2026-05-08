<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <title>Scan Bar Code - TMU Portal</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/quagga/0.12.1/quagga.min.js"></script>
    <style>
        body {
            margin: 0;
            padding: 20px;
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        h1 {
            color: #990033;
            text-align: center;
            margin-bottom: 20px;
        }

        #scanner-container {
            position: relative;
            width: 100%;
            max-width: 640px;
            margin: 0 auto;
            border: 3px solid #990033;
            border-radius: 10px;
            overflow: hidden;
        }

        #interactive.viewport {
            position: relative;
            width: 100%;
        }

        #interactive.viewport canvas,
        #interactive.viewport video {
            width: 100%;
            height: auto;
            display: block;
        }

        #result {
            margin-top: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-left: 4px solid #990033;
            border-radius: 5px;
            display: none;
        }

        #result.show {
            display: block;
        }

        #result h3 {
            color: #990033;
            margin-top: 0;
        }

        #result .barcode-value {
            font-size: 24px;
            font-weight: bold;
            color: #333;
            padding: 10px;
            background-color: white;
            border: 2px dashed #990033;
            border-radius: 5px;
            text-align: center;
            margin: 10px 0;
        }

        .button-container {
            text-align: center;
            margin-top: 20px;
        }

        .btn {
            padding: 12px 30px;
            margin: 5px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            transition: all 0.3s;
        }

        .btn-primary {
            background-color: #990033;
            color: white;
        }

        .btn-primary:hover {
            background-color: #660022;
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #545b62;
        }

        .btn-success {
            background-color: #28a745;
            color: white;
        }

        .btn-success:hover {
            background-color: #218838;
        }

        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: #007bff;
            text-decoration: none;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        .status {
            text-align: center;
            margin-top: 10px;
            color: #666;
            font-style: italic;
        }

        .file-input-container {
            text-align: center;
            margin-top: 15px;
        }

        .file-input-container input[type="file"] {
            display: none;
        }

        .file-input-label {
            padding: 12px 30px;
            background-color: #007bff;
            color: white;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            display: inline-block;
            transition: all 0.3s;
        }

        .file-input-label:hover {
            background-color: #0056b3;
        }

        #file-preview {
            max-width: 640px;
            margin: 15px auto;
            display: none;
            border: 3px solid #007bff;
            border-radius: 10px;
        }
    </style>
</head>

<body>
    <div class="container">
        <h1>📷 Scan Bar Code</h1>

        <div id="scanner-container">
            <div id="interactive" class="viewport"></div>
        </div>

        <p class="status" id="status">Click "Start Scanner" to begin scanning</p>

        <div class="button-container">
            <button class="btn btn-primary" id="start-btn" onclick="startScanner()">Start Scanner</button>
            <button class="btn btn-secondary" id="stop-btn" onclick="stopScanner()" disabled>Stop Scanner</button>
        </div>

        <div class="file-input-container">
            <label for="file-input" class="file-input-label">📁 Upload Barcode Image</label>
            <input type="file" id="file-input" accept="image/*" onchange="handleFileUpload(event)" />
        </div>

        <img id="file-preview" alt="Uploaded barcode" />

        <div id="result">
            <h3>✅ Barcode Detected:</h3>
            <div class="barcode-value" id="barcode-value"></div>
            <p><strong>Format:</strong> <span id="barcode-format"></span></p>
            <div class="button-container">
                <button class="btn btn-success" onclick="copyBarcode()">📋 Copy to Clipboard</button>
            </div>
        </div>

        <p style="text-align: center;">
            <a href="index.html" class="back-link">← Back to Login</a>
        </p>
    </div>

    <script>
        let scannerRunning = false;

        function startScanner() {
            document.getElementById('start-btn').disabled = true;
            document.getElementById('stop-btn').disabled = false;
            document.getElementById('status').textContent = 'Initializing camera...';

            Quagga.init({
                inputStream: {
                    name: "Live",
                    type: "LiveStream",
                    target: document.querySelector('#interactive'),
                    constraints: {
                        facingMode: "environment",
                        width: { ideal: 640 },
                        height: { ideal: 480 }
                    }
                },
                decoder: {
                    readers: [
                        "code_128_reader",
                        "ean_reader",
                        "ean_8_reader",
                        "code_39_reader",
                        "code_39_vin_reader",
                        "codabar_reader",
                        "upc_reader",
                        "upc_e_reader"
                    ]
                },
                locate: true
            }, function (err) {
                if (err) {
                    console.error(err);
                    document.getElementById('status').textContent = 'Error: Could not access camera. Please allow camera access.';
                    document.getElementById('start-btn').disabled = false;
                    document.getElementById('stop-btn').disabled = true;
                    return;
                }

                document.getElementById('status').textContent = 'Scanner active - Point camera at barcode';
                scannerRunning = true;
                Quagga.start();
            });

            Quagga.onDetected(onBarcodeDetected);
        }

        function stopScanner() {
            if (scannerRunning) {
                Quagga.stop();
                scannerRunning = false;
                document.getElementById('interactive').innerHTML = '';
                document.getElementById('status').textContent = 'Scanner stopped';
                document.getElementById('start-btn').disabled = false;
                document.getElementById('stop-btn').disabled = true;
            }
        }

        function onBarcodeDetected(result) {
            const code = result.codeResult.code;
            const format = result.codeResult.format;

            document.getElementById('barcode-value').textContent = code;
            document.getElementById('barcode-format').textContent = format;
            document.getElementById('result').classList.add('show');
            document.getElementById('status').textContent = 'Barcode detected!';

            // Play beep sound
            playBeep();

            // Flash effect
            flashDetection();
        }

        function handleFileUpload(event) {
            const file = event.target.files[0];
            if (!file) return;

            const reader = new FileReader();
            reader.onload = function (e) {
                const imgPreview = document.getElementById('file-preview');
                imgPreview.src = e.target.result;
                imgPreview.style.display = 'block';

                document.getElementById('status').textContent = 'Scanning uploaded image...';

                Quagga.decodeSingle({
                    src: e.target.result,
                    inputStream: {
                        size: 800,
                        singleChannel: false
                    },
                    locator: {
                        patchSize: "medium",
                        halfSample: false
                    },
                    numOfWorkers: 2,
                    decoder: {
                        readers: [
                            "code_128_reader",
                            "ean_reader",
                            "ean_8_reader",
                            "code_39_reader",
                            "code_39_vin_reader",
                            "codabar_reader",
                            "upc_reader",
                            "upc_e_reader"
                        ]
                    },
                    locate: true
                }, function (result) {
                    if (result && result.codeResult) {
                        document.getElementById('barcode-value').textContent = result.codeResult.code;
                        document.getElementById('barcode-format').textContent = result.codeResult.format;
                        document.getElementById('result').classList.add('show');
                        document.getElementById('status').textContent = 'Barcode found in image!';
                        playBeep();
                    } else {
                        document.getElementById('status').textContent = 'No barcode found in this image. Try another image.';
                        document.getElementById('result').classList.remove('show');
                    }
                });
            };
            reader.readAsDataURL(file);
        }

        function copyBarcode() {
            const barcode = document.getElementById('barcode-value').textContent;
            navigator.clipboard.writeText(barcode).then(() => {
                alert('Barcode copied to clipboard: ' + barcode);
            }).catch(err => {
                console.error('Failed to copy: ', err);
                // Fallback for older browsers
                const textarea = document.createElement('textarea');
                textarea.value = barcode;
                document.body.appendChild(textarea);
                textarea.select();
                document.execCommand('copy');
                document.body.removeChild(textarea);
                alert('Barcode copied to clipboard: ' + barcode);
            });
        }

        function playBeep() {
            try {
                const audioContext = new (window.AudioContext || window.webkitAudioContext)();
                const oscillator = audioContext.createOscillator();
                const gainNode = audioContext.createGain();

                oscillator.connect(gainNode);
                gainNode.connect(audioContext.destination);

                oscillator.frequency.value = 800;
                oscillator.type = 'sine';

                gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
                gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.1);

                oscillator.start(audioContext.currentTime);
                oscillator.stop(audioContext.currentTime + 0.1);
            } catch (e) {
                console.log('Audio not supported');
            }
        }

        function flashDetection() {
            const container = document.getElementById('scanner-container');
            container.style.boxShadow = '0 0 20px 5px #28a745';
            setTimeout(() => {
                container.style.boxShadow = 'none';
            }, 300);
        }

        // Cleanup on page unload
        window.addEventListener('beforeunload', function () {
            if (scannerRunning) {
                Quagga.stop();
            }
        });
    </script>
</body>

</html>