unit MainFrm;

interface

uses
  UnitService, LoggerPro, Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    Image1: TImage;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    //定义日志字段
    FLog: ILogWriter;
    //定义游戏业务类的对象
    GameService: TGameSevice;
  public
    { Public declarations }
    //定义一个属性，属性是为了防止直接访问我们的字段
    property Log: ILogWriter read FLog write FLog;

    //游戏初始化
    procedure InitGame();
  end;

var
  Form1: TForm1;

implementation

uses
  Unit1Utils, UnitConst, System.Generics.Collections, UnitData,
  LoggerPro.VCLListViewAppender;
{$R *.dfm}



//图片绘制测试

procedure TForm1.FormCreate(Sender: TObject);
var
  RandomIndex: Integer;
begin
  FLog := BuildLogWriter([TVCLListViewAppender.Create(ListView1)]);
  //初始化游戏业务类的对象
  GameService := TGameSevice.Create();

  //创建GameService对象时初始化图形
  RandomIndex := TPublicUtil.GetNumberWithRound(0, 6);

  GameService.CurrentAct := TGameData.GetActByIndex(RandomIndex);
  InitGame;
end;


//当事件发生时会将键盘的键码值传到函数内
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

  case Key of
    VK_UP:
      begin
        GameService.Revolve();
        Log.Info('上', 'VK_UP');
      end;

    VK_DOWN:
      begin
        GameService.Move(0, 1);
        Log.Info('下', 'VK_DOWN');
      end;

    VK_LEFT:
      begin
        GameService.Move(-1, 0);
        Log.Info('左', 'VK_LEFT');
      end;
    VK_RIGHT:
      begin
        GameService.Move(1, 0);
        Log.Info('右', 'VK_RIGHT');
      end;

    VK_SPACE:
      begin

        Log.Info('空格', 'VK_SPACE');
      end;
  end;
end;

procedure TForm1.InitGame;
var
  MapWidth, MapHeight, I: Integer;
begin
    //设置句柄
  GameService.GameHandle := Image1.Canvas.Handle;
  //绘制背景图
  GameService.DrawBackGround(Image1.Width, Image1.Height);
  //绘制游戏主区窗口
  //游戏地图的宽度:=方格的大小*地图宽度总格子数+地图的边框宽度
  MapWidth := UnitConst.ACT_SIZE * Unitconst.GAME_MAP_WIDTH + UnitConst.GAME_WINDOW_BORDER_WIDTH;

  MapHeight := UnitConst.ACT_SIZE * UnitConst.GAME_MAP_HEIGHT + UnitConst.GAME_WINDOW_BORDER_WIDTH;

  GameService.DrawWindow(0, 0, MapWidth, MapHeight);

  //绘制图形预览窗口
  GameService.DrawWindow(MapWidth + 100, 0, 32 * 12, 32 * 8);


  //绘制图形
  for I := 0 to GameService.CurrentAct.Count - 1 do begin

    GameService.DrawAct(7 + GameService.CurrentAct.Items[I].X * 32, 7 + GameService.CurrentAct.Items[I].Y * 32, 1);
  end;

//  GameService.Move(0, 1);

  //TODO 还有其他需要初始化显示的内容
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin

  InitGame;

  //重绘
  Repaint;

//  Log.Info(TPublicUtil.GetNumberWithRound(3, 6).ToString, '随机数');
end;

end.

