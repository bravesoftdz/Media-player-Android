unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Media,
  FMX.TabControl, FMX.StdCtrls, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  System.Actions, FMX.ActnList, FMX.ListBox, FMX.Layouts, FMX.Objects,
  ALFmxObjects, ALVideoPlayer, ALFmxTabControl, FMX.Ani, ALFmxLayouts,
  ALFmxStdCtrls;

type
  TFrmMain = class(TForm)
    ToolBar_Top: TToolBar;
    bToTheStart: TButton;
    b10SecBackward: TButton;
    b10SecForward: TButton;
    bToTheEnd: TButton;
    Timer_Progress: TTimer;
    Btn_Back: TSpeedButton;
    AHeader: TListBoxGroupHeader;
    Btn_Audio: TButton;
    Btn_Video: TButton;
    GridPnLyt_List: TGridPanelLayout;
    PlayerSurface: TALVideoPlayerSurface;
    Txt_Info: TALText;
    TabCtrl_APPP: TALTabControl;
    TabItem_Main: TALTabItem;
    TabItem_Media: TALTabItem;
    Lv_Media: TListView;
    Timer_Info: TTimer;
    Lbl_Progress: TLabel;
    Lyt_Volume: TLayout;
    Lyt_Ctrl: TLayout;
    FAni_OpacityUP: TFloatAnimation;
    FAni_SlideUP: TFloatAnimation;
    Lyt_Progress: TLayout;
    GridPnLyt_Ctrl: TGridPanelLayout;
    FAni_OpacityDown: TFloatAnimation;
    FAni_SlideDown: TFloatAnimation;
    Timer_DoHideCtrls: TTimer;
    Lyt_Info: TALLayout;
    Lyt_SetVolume: TALLayout;
    Lyt_ToolUP: TALLayout;
    Rect_Volume: TALRectangle;
    Rect_Ctrls: TALRectangle;
    TB_Volume: TALTrackBar;
    TB_Position: TALTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure bToTheStartClick(Sender: TObject);
    procedure b10SecBackwardClick(Sender: TObject);
    procedure b10SecForwardClick(Sender: TObject);
    procedure bToTheEndClick(Sender: TObject);
    procedure Timer_ProgressTimer(Sender: TObject);
    procedure Btn_BackClick(Sender: TObject);
    procedure Btn_AudioClick(Sender: TObject);
    procedure Btn_VideoClick(Sender: TObject);
    procedure Lv_MediaItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure Timer_InfoTimer(Sender: TObject);
    procedure FAni_OpacityUPFinish(Sender: TObject);
    procedure FAni_SlideUPFinish(Sender: TObject);
    procedure FAni_SlideDownFinish(Sender: TObject);
    procedure FAni_OpacityDownFinish(Sender: TObject);
    procedure FAni_SlideDownProcess(Sender: TObject);
    procedure FAni_SlideUPProcess(Sender: TObject);
    procedure PlayerSurfaceClick(Sender: TObject);
    procedure Timer_DoHideCtrlsTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TB_VolumeChange(Sender: TObject);
    procedure TB_PositionChange(Sender: TObject);
  private
    { Private declarations }
    FLibrary_Dir: string;
    function Get_Media_Dir: string;
    procedure FillMediaList(AMediaType: TMediaType);
    procedure Hide_Ctrls;
    procedure Show_Ctrls;
    function Get_AudioTrack_Name(AAudioFileName: string): string;
//    procedure Set_Lbl_Progress_Position;
  public
    { Public declarations }
    procedure GlobalMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  end;

var
  FrmMain: TFrmMain;
  AExtension,
  AMedia_Path,
  ADuration: string;
  IS_Land_Scape: Boolean = False;

implementation

uses {$IFDEF ANDROID}
  FMX.Helpers.Android,
  Androidapi.Helpers,
  Androidapi.JNI.Widget,
  Androidapi.JNI.Media,
  Androidapi.JNI.Provider,
  Androidapi.JNI.Net,
  Androidapi.JNI.Os,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Telephony,
  Androidapi.JNI.GraphicsContentViewText, {$ENDIF}System.IOUtils, duck;

{$R *.fmx}

const
  ASecond = 1000;
  TenSecond = 10000;

function msToDuration(AMilliseconds: Cardinal): String;
var
  ATime: Double;
begin
  ATime := AMilliseconds/ MSecsPerDay;
  Result := FormatDateTime('h:nn:ss', ATime);
end;

  { FrmMain }

function TFrmMain.Get_AudioTrack_Name(AAudioFileName: string): string;
begin
  if AAudioFileName = '001' then
   Result := '”Ê—… «·›« Õ…' else
   Result := '”Ê—… «·»ﬁ—…';
end;

function TFrmMain.Get_Media_Dir: string;
begin
  case TOSVersion.Platform of
    TOSVersion.TPlatform.pfWindows:
      Result := '..\..\Media\';
    TOSVersion.TPlatform.pfMacOS:
      Result := TPath.GetFullPath('../Resources/StartUp');
    TOSVersion.TPlatform.pfiOS:
      Result := TPath.GetHomePath + '/Documents';
    TOSVersion.TPlatform.pfAndroid:
      Result := TPath.GetDocumentsPath;
    TOSVersion.TPlatform.pfWinRT, TOSVersion.TPlatform.pfLinux:
      raise Exception.Create('Unexpected platform');
  end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  if TabCtrl_APPP.ActiveTab <> TabItem_Main then
  begin
    TabCtrl_APPP.ActiveTab := TabItem_Main;
  end;

  FLibrary_Dir := Get_Media_Dir;

 Self.duck.all.has('OnMouseDown').each(
    procedure(obj: TObject)
    begin
      if not(obj is TALVideoPlayerSurface)and(TabCtrl_APPP.ActiveTab = TabItem_Media)  then
      begin
        TControl(obj).OnMouseDown := GlobalMouseDown;
      end;
    end);
end;

procedure TFrmMain.FormResize(Sender: TObject);
begin
//  IS_Land_Scape := Width <> 320;
//  Set_Lbl_Progress_Position;
end;

procedure TFrmMain.FAni_OpacityUPFinish(Sender: TObject);
begin
  FAni_OpacityUP.Enabled := False;
end;

procedure TFrmMain.FAni_OpacityDownFinish(Sender: TObject);
begin
  FAni_OpacityDown.Enabled := False;
end;

procedure TFrmMain.FAni_SlideUPFinish(Sender: TObject);
begin
  FAni_SlideUP.Enabled := False;
  if not FAni_SlideUP.Inverse then
  begin
    Lyt_Volume.Visible := False;
  end;
end;

procedure TFrmMain.FAni_SlideUPProcess(Sender: TObject);
begin
  Lyt_Volume.Visible := True;
end;

procedure TFrmMain.FAni_SlideDownFinish(Sender: TObject);
begin
  FAni_SlideDown.Enabled := False;
  if not FAni_SlideDown.Inverse then
  begin
    Lyt_Ctrl.Visible := False;
  end;
end;

procedure TFrmMain.FAni_SlideDownProcess(Sender: TObject);
begin
  Lyt_Ctrl.Visible := True;
end;

procedure TFrmMain.GlobalMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  Timer_DoHideCtrls.Enabled := False;
  Timer_DoHideCtrls.Enabled := True;
end;

procedure TFrmMain.Timer_DoHideCtrlsTimer(Sender: TObject);
begin
  Timer_DoHideCtrls.Enabled := False;
  Hide_Ctrls;
end;

procedure TFrmMain.PlayerSurfaceClick(Sender: TObject);
begin
  if not (Lyt_Ctrl.Visible) then
  begin
    Show_Ctrls;
  end else
  case PlayerSurface.Tag of
    0:
      begin
        PlayerSurface.VideoPlayer.pause;
        PlayerSurface.Tag := 1;
      end;
    1:
      begin
        PlayerSurface.VideoPlayer.Start;
        PlayerSurface.Tag := 0;
      end;
  end;
end;

procedure TFrmMain.Hide_Ctrls;
begin
  FAni_SlideUP.Inverse := False;
  FAni_SlideUP.Enabled := True;
  FAni_OpacityUP.Inverse := False;
  FAni_OpacityUP.Enabled := True;

  FAni_SlideDown.Inverse := False;
  FAni_SlideDown.Enabled := True;
  FAni_OpacityDown.Inverse := False;
  FAni_OpacityDown.Enabled := True;
end;

//procedure TFrmMain.Set_Lbl_Progress_Position;
//var
//  Video_Height,
//  BlackSpace_Height: Single;
//
//begin
//  if not IS_Land_Scape then
//  begin
//    Video_Height := PlayerSurface.VideoPlayer.getVideoHeight;
//    BlackSpace_Height := PlayerSurface.Height - Video_Height;
//    Lbl_Progress.Position.Y := (((BlackSpace_Height) / 2)+ Video_Height) + 3;
//    Lbl_Progress.Visible := True;
//  end else Lbl_Progress.Visible := False;
//end;

procedure TFrmMain.Show_Ctrls;
begin
  if not Lyt_Ctrl.Visible then
  begin
    FAni_SlideUP.Inverse := True;
    FAni_SlideUP.Enabled := True;
    FAni_OpacityUP.Inverse := True;
    FAni_OpacityUP.Enabled := True;

    FAni_SlideDown.Inverse := True;
    FAni_SlideDown.Enabled := True;
    FAni_OpacityDown.Inverse := True;
    FAni_OpacityDown.Enabled := True;
  end;
end;

procedure TFrmMain.Btn_AudioClick(Sender: TObject);
begin
  Lv_Media.Items.Clear;
  Lv_Media.BeginUpdate;
    FillMediaList(TMediaType.Audio);
  Lv_Media.EndUpdate;
end;

procedure TFrmMain.Btn_VideoClick(Sender: TObject);
begin
  Lv_Media.Items.Clear;
  Lv_Media.BeginUpdate;
    FillMediaList(TMediaType.Video);
  Lv_Media.EndUpdate;
end;

procedure TFrmMain.FillMediaList(AMediaType: TMediaType);
var
  F: TSearchRec;
  Path: string;
  Attr: Integer;
  Media_Item: TListViewItem;
begin
  Path := TPath.Combine(FLibrary_Dir, '*.*');
  Attr := faReadOnly + faArchive;
  FindFirst(Path, Attr, F);
  if F.name <> '' then
  begin
    AExtension := TPath.GetExtension(TPath.Combine(FLibrary_Dir, F.name));

    if TMediaCodecManager.GetFilterStringByType(AMediaType).Contains(AExtension)
    then
    begin
      Media_Item := Lv_Media.Items.Add;
      Media_Item.Text := F.name;
    end;

    while FindNext(F) = 0 do
    begin
      AExtension := TPath.GetExtension(TPath.Combine(FLibrary_Dir, F.name));
      if TMediaCodecManager.GetFilterStringByType(AMediaType)
        .Contains(AExtension) then
      begin
        Media_Item := Lv_Media.Items.Add;
        Media_Item.Text := F.name;
      end;
    end;
  end
  else
    case AMediaType of
      TMediaType.Audio:
        ShowMessage('There is no Supported Audios on this device');
      TMediaType.Video:
        ShowMessage('There is no Supported Videos on this device');
    end;

  FindClose(F);
end;

procedure TFrmMain.Lv_MediaItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  // 'http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_30fps_normal.mp4'
  PlayerSurface.resetVideoPlayer;

  AMedia_Path := TPath.Combine(FLibrary_Dir, Lv_Media.Items[Lv_Media.ItemIndex].Text);
  Txt_Info.Text := '';
  Show_Ctrls;

  if TabCtrl_APPP.Next(TALTabTransition.Slide) then
  begin
    if PlayerSurface.VideoPlayer.state in [vpsIdle] then
    begin
      PlayerSurface.VideoPlayer.setLooping(False);
      PlayerSurface.VideoPlayer.prepare(AMedia_Path, true);
    end
    else if PlayerSurface.VideoPlayer.state in [vpsPrepared, vpsPaused] then
      PlayerSurface.VideoPlayer.Start
    else
      PlayerSurface.VideoPlayer.AutoStartWhenPrepared := true;

    PlayerSurface.VideoPlayer.setVolume(0.5);
    TB_Volume.Value := 0.5;

    TB_Position.Max := PlayerSurface.VideoPlayer.getDuration;
    TB_Position.Value := 0;
    Timer_Progress.Enabled := true;
  end;

  Timer_Info.Enabled := True;
end;

procedure TFrmMain.b10SecForwardClick(Sender: TObject);
begin
  if PlayerSurface.VideoPlayer.getCurrentPosition <
    (PlayerSurface.VideoPlayer.getDuration - TenSecond) then
    PlayerSurface.VideoPlayer.seekTo
      (PlayerSurface.VideoPlayer.getCurrentPosition + TenSecond)
  else
    PlayerSurface.VideoPlayer.seekTo(PlayerSurface.VideoPlayer.getDuration);
end;

procedure TFrmMain.b10SecBackwardClick(Sender: TObject);
begin
  if PlayerSurface.VideoPlayer.getCurrentPosition > TenSecond then
    PlayerSurface.VideoPlayer.seekTo
      (PlayerSurface.VideoPlayer.getCurrentPosition - TenSecond)
  else
    PlayerSurface.VideoPlayer.seekTo(0);
end;

procedure TFrmMain.bToTheEndClick(Sender: TObject);
begin
  PlayerSurface.VideoPlayer.seekTo(PlayerSurface.VideoPlayer.getDuration);
end;

procedure TFrmMain.bToTheStartClick(Sender: TObject);
begin
  PlayerSurface.VideoPlayer.seekTo(0);
end;

procedure TFrmMain.Timer_InfoTimer(Sender: TObject);
begin
  Timer_Info.Enabled := False;
//  Set_Lbl_Progress_Position;
    Timer_DoHideCtrls.Enabled := True;
  ADuration := msToDuration(PlayerSurface.VideoPlayer.getDuration);
  AExtension := TPath.GetExtension(AMedia_Path);
  if TMediaCodecManager.GetFilterStringByType(TMediaType.Video)
    .Contains(AExtension) then
  begin
    Txt_Info.Text := 'Pixel:' +
      IntToStr(PlayerSurface.VideoPlayer.getVideoWidth) + 'x' +
      IntToStr(PlayerSurface.VideoPlayer.getVideoHeight);

    Lbl_Progress.Text := '0:00:00/'+ ADuration;
  end
  else
    Txt_Info.Text := Get_AudioTrack_Name(TPath.GetFileNameWithoutExtension(AMedia_Path));
end;

procedure TFrmMain.Timer_ProgressTimer(Sender: TObject);
begin

  if TB_Position.Max <> PlayerSurface.VideoPlayer.getDuration then
    TB_Position.Max := PlayerSurface.VideoPlayer.getDuration;

  TB_Position.Tag := 1;
  if TB_Position.Value <> PlayerSurface.VideoPlayer.getCurrentPosition then
    TB_Position.Value := PlayerSurface.VideoPlayer.getCurrentPosition;
  Lbl_Progress.Text := msToDuration(TB_Position.Value.ToString.ToInteger)+'/'+ ADuration;
  TB_Position.Tag := 0;
end;

procedure TFrmMain.TB_PositionChange(Sender: TObject);
begin
  if TB_Position.Tag = 0 then
  PlayerSurface.VideoPlayer.seekTo(Round(TB_Position.Value));
end;

procedure TFrmMain.TB_VolumeChange(Sender: TObject);
begin
  PlayerSurface.VideoPlayer.setVolume(TB_Volume.Value);
end;

procedure TFrmMain.Btn_BackClick(Sender: TObject);
begin
  Timer_Progress.Enabled := False;

  PlayerSurface.VideoPlayer.pause;
  PlayerSurface.VideoPlayer.Stop;

  if TabCtrl_APPP.Previous(TALTabTransition.Slide) then
  begin
    TB_Position.Value := 0;
  end;

end;

end.
