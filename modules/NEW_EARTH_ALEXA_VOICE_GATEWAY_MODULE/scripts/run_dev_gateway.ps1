# Windows PowerShell dev runner
python -m venv .venv
. .venv\Scripts\Activate.ps1
pip install -r requirements.txt
Start-Process powershell -ArgumentList "-NoExit", "-Command", "python examples/dashboard_mock/mock_dashboard_api.py"
python -m src.voice_gateway.app
