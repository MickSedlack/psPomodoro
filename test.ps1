using namespace System.Drawing
using namespace System.Windows.Forms

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

$code = @"
    [System.Runtime.InteropServices.DllImport("Shcore.dll")]
    public static extern int SetProcessDpiAwareness(int dpiAwarenessMode);
"@
$PInvoke = Add-Type -MemberDefinition $code -Name "PInvoke" -PassThru
$null = $PInvoke::SetProcessDpiAwareness(2)

$form = [Form] @{
    AutoScaleMode = [AutoScaleMode]::Dpi;
    ClientSize = [Point]::new(200, 200);
    StartPosition = [FormStartPosition]::CenterScreen;
    Text = "Visual Styles";
}

$button = [Button] @{
    Font = [Font]::new("Segoe UI", 20)
    Location = [Point]::new(20, 20)
    Size = [Size]::new(40, 40)
    Text = [char]::ConvertFromUtf32(0x0001F6F3)
    UseVisualStyleBackColor = $true
}

$form.Controls.Add($button)
$form.ShowDialog()