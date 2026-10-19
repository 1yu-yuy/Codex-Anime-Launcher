param([switch]$ValidateOnly,[switch]$SmokeTest,[double]$PreviewTime=2.85)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
$appId = 'OpenAI.Codex_2p2nqsd0c76g0!App'
$basePath = $PSScriptRoot
$script:soundPlayer=$null
if(-not $ValidateOnly){
 try{
  $script:soundPlayer=New-Object System.Media.SoundPlayer (Join-Path $basePath 'startup-sfx.wav')
  $script:soundPlayer.Load()
 }catch{$script:soundPlayer=$null}
}
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Width="1152" Height="648" WindowState="Maximized" WindowStyle="None" ResizeMode="NoResize" AllowsTransparency="True" Background="Transparent" Topmost="True" ShowInTaskbar="False" Title="Codex Startup" UseLayoutRounding="True">
 <Viewbox Stretch="UniformToFill"><Grid Name="Stage" Width="1152" Height="648" ClipToBounds="True">
 <Grid ClipToBounds="True" Name="Root" Opacity="0"><Grid.RenderTransform><TranslateTransform/></Grid.RenderTransform>
  <Grid.Background><SolidColorBrush Color="#05070B"/></Grid.Background>
  <Image Name="Art" Stretch="UniformToFill" RenderTransformOrigin="0.5,0.5"><Image.RenderTransform><ScaleTransform ScaleX="1.1" ScaleY="1.1"/></Image.RenderTransform></Image>
  <Grid Name="LeftCut" Opacity="0"><Grid.Clip><PathGeometry Figures="M 0,0 L 485,0 L 710,648 L 0,648 Z"/></Grid.Clip><Grid.RenderTransform><TranslateTransform X="-900"/></Grid.RenderTransform><Image Name="LeftArt" Stretch="UniformToFill"/><Path Data="M 485,0 L 710,648" Stroke="#FF3854" StrokeThickness="4"><Path.Effect><DropShadowEffect Color="#FF163D" BlurRadius="22" ShadowDepth="0"/></Path.Effect></Path></Grid>
  <Grid Name="RightCut" Opacity="0"><Grid.Clip><PathGeometry Figures="M 667,0 L 1152,0 L 1152,648 L 442,648 Z"/></Grid.Clip><Grid.RenderTransform><TranslateTransform X="900"/></Grid.RenderTransform><Image Name="RightArt" Stretch="UniformToFill"/><Path Data="M 667,0 L 442,648" Stroke="#FFB253" StrokeThickness="4"><Path.Effect><DropShadowEffect Color="#FF7A16" BlurRadius="22" ShadowDepth="0"/></Path.Effect></Path></Grid>
  <Rectangle IsHitTestVisible="False"><Rectangle.Fill><LinearGradientBrush StartPoint="0,0" EndPoint="1,0"><GradientStop Color="#18000000" Offset="0"/><GradientStop Color="#10000000" Offset="0.3"/><GradientStop Color="#BB030712" Offset="0.5"/><GradientStop Color="#10000000" Offset="0.7"/><GradientStop Color="#18000000" Offset="1"/></LinearGradientBrush></Rectangle.Fill></Rectangle>
  <Canvas Name="Particles" IsHitTestVisible="False"/>
  <Canvas Name="ActionFX" IsHitTestVisible="False">
   <Ellipse Name="Ring" Width="180" Height="180" Canvas.Left="486" Canvas.Top="234" Stroke="#FFB75D" StrokeThickness="3" Opacity="0" RenderTransformOrigin="0.5,0.5"><Ellipse.RenderTransform><ScaleTransform/></Ellipse.RenderTransform><Ellipse.Effect><DropShadowEffect Color="#FF6618" ShadowDepth="0" BlurRadius="22"/></Ellipse.Effect></Ellipse>
   <Path Name="Bolt" Data="M 70,80 L 235,210 L 197,220 L 422,350 L 360,345 L 576,425 M 1080,70 L 950,210 L 990,212 L 780,330 L 820,330 L 576,425" Stroke="#FFB75A" StrokeThickness="3" Opacity="0"><Path.Effect><DropShadowEffect Color="#FF4422" ShadowDepth="0" BlurRadius="16"/></Path.Effect></Path>
   <Rectangle Name="Slash" Width="28" Height="1100" Fill="#FFF0CC" Canvas.Left="-300" Canvas.Top="-220" Opacity="0"><Rectangle.RenderTransform><TransformGroup><RotateTransform Angle="-25"/><TranslateTransform/></TransformGroup></Rectangle.RenderTransform><Rectangle.Effect><DropShadowEffect Color="#FF9F35" ShadowDepth="0" BlurRadius="30"/></Rectangle.Effect></Rectangle>
  </Canvas>
  <Grid Name="TitlePanel" Opacity="0" VerticalAlignment="Center" HorizontalAlignment="Center" RenderTransformOrigin="0.5,0.5"><Grid.RenderTransform><ScaleTransform ScaleX="1.45" ScaleY="1.45"/></Grid.RenderTransform>
   <StackPanel HorizontalAlignment="Center">
    <TextBlock Text="Codex" FontFamily="Arial" FontWeight="Black" FontSize="92" HorizontalAlignment="Center" Foreground="#FFF2D7"><TextBlock.Effect><DropShadowEffect Color="#FF922F" ShadowDepth="0" BlurRadius="35" Opacity="0.85"/></TextBlock.Effect></TextBlock>
    <TextBlock Text="热 血 启 航" FontFamily="Microsoft YaHei" FontSize="26" Foreground="#FFD095" HorizontalAlignment="Center" Margin="0,-5,0,22"/>
    <TextBlock Text="I G N I T E   Y O U R   I M A G I N A T I O N" FontSize="10" Foreground="#CCDCE7" HorizontalAlignment="Center"/>
    <Grid Width="250" Height="2" Margin="0,38,0,15" Background="#35FFFFFF"><Rectangle Name="Progress" Fill="#FFB463" HorizontalAlignment="Left" Width="0"><Rectangle.Effect><DropShadowEffect Color="#FF8E2B" ShadowDepth="0" BlurRadius="15"/></Rectangle.Effect></Rectangle></Grid>
    <TextBlock Name="Status" Text="A W A K E N I N G" FontSize="10" Foreground="#DDCDB6" HorizontalAlignment="Center"/>
   </StackPanel>
  </Grid>
  <Rectangle Name="Flash" Fill="#FFF0D0" Opacity="0" IsHitTestVisible="False"/>
  <Border Height="40" Background="#E805070B" VerticalAlignment="Top"><Grid Margin="28,0"><TextBlock Text="—   T H E   W I L L   T O   E X P L O R E" Foreground="#C3AE94" FontSize="9" VerticalAlignment="Center"/><Button Name="Skip" Content="跳过  ›" HorizontalAlignment="Right" VerticalAlignment="Center" Foreground="#D9C4A9" Background="Transparent" BorderThickness="0" Padding="12,5" Cursor="Hand"/></Grid></Border>
  <Border Height="40" Background="#E805070B" VerticalAlignment="Bottom"><Grid Margin="28,0"><TextBlock Text="MONKEY D. LUFFY" Foreground="#DDCBB7" FontSize="10" VerticalAlignment="Center"/><TextBlock Text="PORTGAS D. ACE" Foreground="#DDCBB7" FontSize="10" VerticalAlignment="Center" HorizontalAlignment="Right"/></Grid></Border>
 </Grid>
 <Grid Name="ZoroLayer" IsHitTestVisible="False" Opacity="0" RenderTransformOrigin="0.5,0.5"><Grid.RenderTransform><TransformGroup><ScaleTransform ScaleX="0.5" ScaleY="0.5"/><RotateTransform Angle="-10"/><TranslateTransform Y="60"/></TransformGroup></Grid.RenderTransform>
  <Ellipse Width="400" Height="400" Stroke="#6499FFCB" StrokeThickness="2"><Ellipse.Effect><DropShadowEffect Color="#12F0A0" ShadowDepth="0" BlurRadius="35"/></Ellipse.Effect></Ellipse>
  <Image Name="ZoroArt" Width="1040" Height="610" Stretch="Uniform"><Image.Effect><DropShadowEffect Color="#22ECAC" ShadowDepth="0" BlurRadius="18" Opacity="0.65"/></Image.Effect></Image>
  <TextBlock Text="三 刀 流" VerticalAlignment="Bottom" HorizontalAlignment="Center" Margin="0,0,0,58" FontFamily="Microsoft YaHei" FontWeight="Bold" FontSize="22" Foreground="#D4FFE7"><TextBlock.Effect><DropShadowEffect Color="#00FFAF" ShadowDepth="0" BlurRadius="12"/></TextBlock.Effect></TextBlock>
 </Grid>
 <Canvas Name="ExitOverlay" IsHitTestVisible="False" Opacity="0"/>
 </Grid></Viewbox>
</Window>
'@
$reader = New-Object System.Xml.XmlNodeReader $xaml
$win = [Windows.Markup.XamlReader]::Load($reader)
$root=$win.FindName('Root');$art=$win.FindName('Art');$panel=$win.FindName('TitlePanel');$progress=$win.FindName('Progress');$status=$win.FindName('Status');$flash=$win.FindName('Flash');$particles=$win.FindName('Particles')
$bmp=New-Object Windows.Media.Imaging.BitmapImage
$bmp.BeginInit();$bmp.UriSource=[uri](Join-Path $basePath 'luffy-ace.png');$bmp.CacheOption='OnLoad';$bmp.EndInit();$art.Source=$bmp
$win.FindName('LeftArt').Source=$bmp;$win.FindName('RightArt').Source=$bmp
$zoroBitmap=New-Object Windows.Media.Imaging.BitmapImage
$zoroBitmap.BeginInit();$zoroBitmap.UriSource=[uri](Join-Path $basePath 'zoro-three-sword.png');$zoroBitmap.CacheOption='OnLoad';$zoroBitmap.EndInit();$win.FindName('ZoroArt').Source=$zoroBitmap
$zoro=$win.FindName('ZoroLayer');$exitOverlay=$win.FindName('ExitOverlay')
$script:bladeLines=@()
foreach($angle in @(-32,32,90)){
 $blade=New-Object Windows.Shapes.Line;$blade.X1=-1000;$blade.X2=1000;$blade.Y1=0;$blade.Y2=0;$blade.Stroke=[Windows.Media.Brushes]::MintCream;$blade.StrokeThickness=4
 $glow=New-Object Windows.Media.Effects.DropShadowEffect;$glow.Color=[Windows.Media.ColorConverter]::ConvertFromString('#45FFB8');$glow.BlurRadius=24;$glow.ShadowDepth=0;$blade.Effect=$glow
 $transforms=New-Object Windows.Media.TransformGroup;$transforms.Children.Add([Windows.Media.ScaleTransform]::new(0,1));$transforms.Children.Add([Windows.Media.RotateTransform]::new($angle));$transforms.Children.Add([Windows.Media.TranslateTransform]::new(576,324));$blade.RenderTransform=$transforms
 $exitOverlay.Children.Add($blade) | Out-Null;$script:bladeLines+=,$blade
}
$left=$win.FindName('LeftCut');$right=$win.FindName('RightCut');$ring=$win.FindName('Ring');$bolt=$win.FindName('Bolt');$slash=$win.FindName('Slash');$fx=$win.FindName('ActionFX')
function Animate($obj,$prop,[double]$from,[double]$to,[double]$seconds,[double]$delay=0){
 $a=New-Object Windows.Media.Animation.DoubleAnimation
 $a.From=$from;$a.To=$to;$a.Duration=[Windows.Duration]::new([TimeSpan]::FromSeconds($seconds));$a.BeginTime=[TimeSpan]::FromSeconds($delay)
 $e=New-Object Windows.Media.Animation.CubicEase;$e.EasingMode='EaseOut';$a.EasingFunction=$e
 $obj.BeginAnimation($prop,$a)
}
$script:launchDone=$false;$script:appStarted=$false;$script:handoffStarted=$false
function Start-Codex {
 if($script:appStarted -or $SmokeTest -or $ValidateOnly){return}
 Start-Process -FilePath 'explorer.exe' -ArgumentList ('shell:AppsFolder\'+$appId)
 $script:appStarted=$true
}
function Open-GPT {
 if($script:launchDone){return};$script:launchDone=$true
 if($script:timer){$script:timer.Stop()}
 if($script:renderHandler){[Windows.Media.CompositionTarget]::remove_Rendering($script:renderHandler)}
 if($script:soundPlayer){$script:soundPlayer.Stop();$script:soundPlayer.Dispose();$script:soundPlayer=$null}
 Start-Codex
 $win.Close()
}
$win.FindName('Skip').Add_Click({Open-GPT})
$win.Add_KeyDown({if($_.Key -eq 'Escape' -or $_.Key -eq 'Enter'){Open-GPT}})
$script:sparks=@();$random=New-Object Random 42
for($i=0;$i -lt 36;$i++){
 $s=New-Object Windows.Shapes.Ellipse;$size=$random.Next(2,5);$s.Width=$size;$s.Height=$size*1.6
 $s.Fill=[Windows.Media.Brushes]::Orange;$s.Opacity=$random.NextDouble()*.7+.2
 $particles.Children.Add($s) | Out-Null
 $script:sparks+=,[pscustomobject]@{Shape=$s;X=$random.Next(0,1152);Y=$random.Next(0,648);Speed=$random.Next(25,100);Phase=$random.NextDouble()*6.28}
}
$script:streaks=@()
for($i=0;$i -lt 20;$i++){
 $streak=New-Object Windows.Shapes.Line;$streak.Stroke=if($i%2){[Windows.Media.Brushes]::OrangeRed}else{[Windows.Media.Brushes]::Gold};$streak.StrokeThickness=1+$random.NextDouble()*2
 $fx.Children.Insert(0,$streak);$script:streaks+=,[pscustomobject]@{Shape=$streak;Angle=$random.NextDouble()*6.283;Offset=$random.NextDouble()}
}
function Ease([double]$v){$v=[Math]::Max(0,[Math]::Min(1,$v));return 1-[Math]::Pow(1-$v,3)}
function Scene([double]$t){
 $root.Opacity=Ease ($t/.3)
 $art.Opacity=.12+.88*(Ease (($t-2.1)/1.1))
 $zoom=1.12-.12*(Ease ($t/7));$art.RenderTransform.ScaleX=$zoom;$art.RenderTransform.ScaleY=$zoom
 $cutOpacity=1-(Ease (($t-2.7)/.8));$left.Opacity=(Ease (($t-.2)/.12))*$cutOpacity;$right.Opacity=(Ease (($t-.85)/.12))*$cutOpacity
 $left.RenderTransform.X=-1000*(1-(Ease (($t-.2)/.65)));$right.RenderTransform.X=1000*(1-(Ease (($t-.85)/.65)))
 $titleIn=Ease (($t-2.65)/.55);$panel.Opacity=$titleIn
 $titleScale=1+.9*(1-$titleIn);$panel.RenderTransform.ScaleX=$titleScale;$panel.RenderTransform.ScaleY=$titleScale
 $burst=[Math]::Max(0,1-[Math]::Abs(($t-2.85)/.45));$flash.Opacity=$burst*.32
 $shake=([Math]::Exp(-[Math]::Pow(($t-.82)/.16,2))*7)+([Math]::Exp(-[Math]::Pow(($t-1.48)/.16,2))*7)+([Math]::Exp(-[Math]::Pow(($t-2.95)/.25,2))*10)
 $root.RenderTransform.X=[Math]::Sin($t*83)*$shake;$root.RenderTransform.Y=[Math]::Cos($t*71)*$shake*.55
 $r=Ease (($t-2.72)/1.1);$ring.Opacity=if($t -ge 2.72){(1-$r)*.95}else{0};$ring.RenderTransform.ScaleX=.2+$r*7;$ring.RenderTransform.ScaleY=.2+$r*7
 $bolt.Opacity=if($t -gt 1.5 -and $t -lt 3.2){(.35+.45*[Math]::Abs([Math]::Sin($t*16)))*(1-(Ease (($t-2.7)/.5)))}else{0}
 $sweep=Ease (($t-1.85)/.55);$slash.Opacity=if($t -ge 1.85 -and $t -lt 2.5){[Math]::Sin($sweep*[Math]::PI)*.8}else{0};$slash.RenderTransform.Children[1].X=$sweep*1900
 foreach($s in $script:streaks){$phase=($t*1.3+$s.Offset)%1;$radius=150+$phase*750;$length=45+$phase*200;$s.Shape.X1=576+[Math]::Cos($s.Angle)*$radius;$s.Shape.Y1=324+[Math]::Sin($s.Angle)*$radius;$s.Shape.X2=576+[Math]::Cos($s.Angle)*($radius+$length);$s.Shape.Y2=324+[Math]::Sin($s.Angle)*($radius+$length);$s.Shape.Opacity=(1-$phase)*.65*(1-(Ease (($t-3.1)/.8)))*(Ease ($t/.4))}
 $progress.Width=250*(Ease (($t-3.3)/3.4))
 foreach($s in $script:sparks){[Windows.Controls.Canvas]::SetLeft($s.Shape,$s.X+[Math]::Sin($t+$s.Phase)*18);$y=648-(($s.Y+$t*$s.Speed)%700);[Windows.Controls.Canvas]::SetTop($s.Shape,$y)}
 if($t -gt 6.8){$status.Text='S Y S T E M   R E A D Y';$status.Foreground=[Windows.Media.Brushes]::Aquamarine}
}
function Begin-Handoff {
 if($script:handoffStarted){return};$script:handoffStarted=$true
 $root.RenderTransform.X=0;$root.RenderTransform.Y=0
 $cuts=New-Object Windows.Media.GeometryGroup;$cuts.FillRule='Nonzero'
 $index=0
 foreach($angle in @(-32,32,90)){
  $cut=[Windows.Media.RectangleGeometry]::new([Windows.Rect]::new(-1100,0,2200,0))
  $transforms=New-Object Windows.Media.TransformGroup;$transforms.Children.Add([Windows.Media.RotateTransform]::new($angle));$transforms.Children.Add([Windows.Media.TranslateTransform]::new(576,324));$cut.Transform=$transforms;$cuts.Children.Add($cut)
  $a=New-Object Windows.Media.Animation.RectAnimation;$a.From=[Windows.Rect]::new(-1100,0,2200,0);$a.To=[Windows.Rect]::new(-1100,-750,2200,1500);$a.Duration=[Windows.Duration]::new([TimeSpan]::FromSeconds(.52));$a.BeginTime=[TimeSpan]::FromSeconds(.12+$index*.07)
  $e=New-Object Windows.Media.Animation.CubicEase;$e.EasingMode='EaseOut';$a.EasingFunction=$e
  $cut.BeginAnimation([Windows.Media.RectangleGeometry]::RectProperty,$a)
  Animate $script:bladeLines[$index].RenderTransform.Children[0] ([Windows.Media.ScaleTransform]::ScaleXProperty) 0 1 .12 ($index*.07)
  Animate $script:bladeLines[$index] ([Windows.UIElement]::OpacityProperty) 1 0 .32 (.25+$index*.07)
  $index++
 }
 $root.Clip=[Windows.Media.CombinedGeometry]::new([Windows.Media.GeometryCombineMode]::Exclude,[Windows.Media.RectangleGeometry]::new([Windows.Rect]::new(0,0,1152,648)),$cuts)
 $exitOverlay.Opacity=1
 Animate $zoro.RenderTransform.Children[0] ([Windows.Media.ScaleTransform]::ScaleXProperty) 1.05 1.32 .32
 Animate $zoro.RenderTransform.Children[0] ([Windows.Media.ScaleTransform]::ScaleYProperty) 1.05 1.32 .32
 Animate $zoro.RenderTransform.Children[1] ([Windows.Media.RotateTransform]::AngleProperty) -5 7 .22
 Animate $zoro.RenderTransform.Children[2] ([Windows.Media.TranslateTransform]::YProperty) 0 20 .25
 Animate $zoro ([Windows.UIElement]::OpacityProperty) 1 0 .25 .2
 Animate $win ([Windows.UIElement]::OpacityProperty) 1 0 .18 .65
}
function Zoro-Entrance([double]$time){
 $linear=[Math]::Max(0,[Math]::Min(1,($time-2.15)/.82));$p=$linear*$linear*(3-2*$linear)
 $zoro.Opacity=[Math]::Min(1,$linear*5)
 $zoro.RenderTransform.Children[0].ScaleX=.08+.97*$p;$zoro.RenderTransform.Children[0].ScaleY=.08+.97*$p
 $zoro.RenderTransform.Children[1].Angle=-14+9*$p;$zoro.RenderTransform.Children[2].Y=45*(1-$p)
 $panel.Opacity*=1-$p
 $art.Opacity*=1-.94*$p;$left.Opacity*=1-$p;$right.Opacity*=1-$p
 $particles.Opacity=1-.75*$p
}
$script:clock=[Diagnostics.Stopwatch]::new()
$script:renderHandler=[EventHandler]{
 $t=$script:clock.Elapsed.TotalSeconds
 if($t -gt .15){Start-Codex}
 if(-not $script:handoffStarted){Scene ($t*2.12);Zoro-Entrance $t}
 if($t -ge 3.05){Begin-Handoff}
 if($t -ge 4.08){Open-GPT}
}
$win.Add_ContentRendered({
 Scene 0
 if($script:soundPlayer){$script:soundPlayer.Play()}
 $script:clock.Start();[Windows.Media.CompositionTarget]::add_Rendering($script:renderHandler)
})
if($ValidateOnly){
 Scene ($PreviewTime*2.12);Zoro-Entrance $PreviewTime
 $stage=$win.FindName('Stage');$stage.Measure([Windows.Size]::new(1152,648));$stage.Arrange([Windows.Rect]::new(0,0,1152,648));$stage.UpdateLayout()
 $preview=[Windows.Media.Imaging.RenderTargetBitmap]::new(1152,648,96,96,[Windows.Media.PixelFormats]::Pbgra32);$preview.Render($stage)
 $encoder=New-Object Windows.Media.Imaging.PngBitmapEncoder;$encoder.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create($preview))
 $stream=[IO.File]::Create((Join-Path $basePath 'preview.png'));$encoder.Save($stream);$stream.Dispose();Write-Output 'WPF layout validated';exit
}
try{$win.ShowDialog() | Out-Null}finally{if(-not $script:launchDone){Open-GPT}}
