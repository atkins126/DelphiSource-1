unit UnitService;
{*------------------------------------------------------------------------------
  @author  侯叶飞
  @version 2020/01/28 1.0 Initial revision.
  @comment  游戏的业务控制

   图形移动

   1、获取当前图形的数据(四个小方格的坐标)

   2、改变每个小方格的坐标即可

   3、边界问题


  笛卡尔积坐标系90度旋转公式

  o为中心点、a为当前点、b为目标点

  注意：笛卡尔积坐标系和屏幕坐标系正好相反

  顺时针：

  b.x=o.x-o.y+a.y

  b.y=o.x+o.y-a.x

  逆时针

  a.x=o.y+o.x-b.y
  a.y=o.y-o.x+b.x
-------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Generics.Collections, System.IOUtils, Winapi.Windows,
  Winapi.GDIPOBJ, Winapi.GDIPAPI;

type
  TGameSevice = class
  private
   //定义属性
    FHdc: HDC;
    //表示图片的编号
    FImageIndex: Integer;
    //当前的图形
    FCurrentAct: TList<TPoint>;
  public
    //绘制图片
    procedure DrawImage(FileName: string; Width, Hegiht: Integer);
    //绘制背景
    procedure DrawBackGround(Width, Hegiht: Integer);

    //绘制窗口
    procedure DrawWindow(x, y, w, h: Integer);

    //绘制方块
    procedure DrawAct(x, y, ActIndex: Integer);


    //移动
    function Move(X, Y: Integer): Boolean;



    //构造方法，方法名相同，参数列表不同称为重载
    constructor Create(hdc: HDC); overload;
    constructor Create(); overload;
    //定义字段
    property GameHandle: HDC read FHdc write FHdc;
    property ImageIndex: Integer read FImageIndex write FImageIndex;

    //当前图形的属性
    property CurrentAct: TList<TPoint> read FCurrentAct write FCurrentAct;
  end;

implementation

uses
  MainFrm, UnitConst;
{ TGameSevice }

constructor TGameSevice.Create(hdc: hdc);
begin
  GameHandle := hdc;
end;

constructor TGameSevice.Create;
begin
  inherited;
end;

{*------------------------------------------------------------------------------
  根据指定的编号绘制不同颜色的方块

  @param ActIndex  方块的索引，从0开始
-------------------------------------------------------------------------------}

procedure TGameSevice.DrawAct(x, y, ActIndex: Integer);
var
  //画笔
  Graphics: TGPGraphics;
  Image: TGPImage;
begin
  //载入我们的图片文件
  Image := TGPImage.Create(UnitConst.GAME_ACT_IMAGE);
  //将载入的图片绘制到指定的组件上(TImage)
  Graphics := TGPGraphics.Create(GameHandle);
  //绘制图片
  Graphics.DrawImage(Image, MakeRect(x, y, UnitConst.ACT_SIZE, UnitConst.ACT_SIZE), ActIndex * UnitConst.ACT_SIZE, 0, UnitConst.ACT_SIZE, UnitConst.ACT_SIZE, UnitPixel);
  Graphics.Free;
  Image.Free;

end;

procedure TGameSevice.DrawBackGround(Width, Hegiht: Integer);
var
  ImageList: TArray<string>;
begin
  //获取图片列表
  ImageList := TDirectory.GetFiles(UnitConst.BACK_GROUND_IMAGE);

  if ImageIndex >= Length(ImageList) then begin
    ImageIndex := 0;
  end;

  //选取图片列表中的某一个图片，展示在窗口
  DrawImage(ImageList[ImageIndex], Width, Hegiht);
end;

procedure TGameSevice.DrawImage(FileName: string; Width, Hegiht: Integer);
var
  //画笔
  Graphics: TGPGraphics;
  Image: TGPImage;
begin
  //载入我们的图片文件
  Image := TGPImage.Create(FileName);
  //将载入的图片绘制到指定的组件上(TImage)
  Graphics := TGPGraphics.Create(GameHandle);
  //绘制图片
  Graphics.DrawImage(Image, MakeRect(0, 0, Width, Hegiht));
  Graphics.Free;
  Image.Free;
end;

{*------------------------------------------------------------------------------
  绘制游戏窗口

  @param x 游戏窗口的X坐标
  @param y 游戏窗口的Y坐标
  @param w 游戏窗口的宽度
  @param h 游戏窗口的高度
-------------------------------------------------------------------------------}
procedure TGameSevice.DrawWindow(x, y, w, h: Integer);
var
  //画笔
  Graphics: TGPGraphics;
  img: TGPImage;
begin
  //载入我们的图片文件
  img := TGPImage.Create(UnitConst.GAME_WINDOW);
  //将载入的图片绘制到指定的组件上(TImage)
  Graphics := TGPGraphics.Create(GameHandle);
  //绘制图片
    // 左上角
  Graphics.DrawImage(img, MakeRect(x, y, UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH), 0, 0, UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitPixel);

    // 左侧竖线
  Graphics.DrawImage(img, MakeRect(x, y + UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH, h - UnitConst.GAME_WINDOW_BORDER_WIDTH), 0, UnitConst.GAME_WINDOW_BORDER_WIDTH, img.GetWidth - (img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH), img.GetHeight - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, UnitPixel);

    // 左下角
  Graphics.DrawImage(img, MakeRect(x, y + h, UnitConst.GAME_WINDOW_BORDER_WIDTH, img.GetHeight), 0, img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH, img.GetHeight, UnitPixel);

    // 底部中线
  Graphics.DrawImage(img, MakeRect(x + UnitConst.GAME_WINDOW_BORDER_WIDTH, y + h, w - UnitConst.GAME_WINDOW_BORDER_WIDTH, img.GetHeight), UnitConst.GAME_WINDOW_BORDER_WIDTH, img.GetHeight - UnitConst.GAME_WINDOW_BORDER_WIDTH, img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, img.GetHeight, UnitPixel);

    // 右下角
  Graphics.DrawImage(img, MakeRect(x + w, y + h, img.GetWidth, img.GetHeight), img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH, img.GetHeight - UnitConst.GAME_WINDOW_BORDER_WIDTH, img.GetWidth, img.GetHeight, UnitPixel);
    // 右侧竖线
  Graphics.DrawImage(img, MakeRect(x + w, y + UnitConst.GAME_WINDOW_BORDER_WIDTH, img.GetWidth, h - UnitConst.GAME_WINDOW_BORDER_WIDTH), img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH, img.GetWidth, img.GetHeight - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, UnitPixel);

    // 右上角
  Graphics.DrawImage(img, MakeRect(x + w, y, img.GetHeight, UnitConst.GAME_WINDOW_BORDER_WIDTH), img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH, 0, img.GetHeight, UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitPixel);
    // 顶部中线
  Graphics.DrawImage(img, MakeRect(x + UnitConst.GAME_WINDOW_BORDER_WIDTH, y, w - UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH), UnitConst.GAME_WINDOW_BORDER_WIDTH, 0, img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitPixel);

    // 中间
  Graphics.DrawImage(img, MakeRect(x + UnitConst.GAME_WINDOW_BORDER_WIDTH, y + UnitConst.GAME_WINDOW_BORDER_WIDTH, w - UnitConst.GAME_WINDOW_BORDER_WIDTH, h - UnitConst.GAME_WINDOW_BORDER_WIDTH), UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH, img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, img.GetHeight - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, UnitPixel);
  Graphics.Free;
  img.Free;

end;

{*------------------------------------------------------------------------------
  图形移动

  @param X 目的地的X
  @param Y 目的地的Y
  @return   可以继续移动返回true，否则返回false
-------------------------------------------------------------------------------}

function TGameSevice.Move(X, Y: Integer): Boolean;
var
  NewX, NewY, I: Integer;
begin
  for I := 0 to CurrentAct.Count - 1 do begin

    //获取当前图形中每个方格的坐标

    NewX := CurrentAct.Items[I].X + X;      //10+ -2

    NewY := CurrentAct.Items[I].Y + Y;

    if (NewY >= UnitConst.GAME_MAP_HEIGHT) or (NewX >= UnitConst.GAME_MAP_WIDTH) or (NewX < 0) then begin

      Result := False;
      Exit;
    end;

  end;

  for I := 0 to CurrentAct.Count - 1 do begin

    //获取当前图形中每个方格的坐标

    NewX := CurrentAct.Items[I].X + X;      //10+ -2

    NewY := CurrentAct.Items[I].Y + Y;

    //重新赋值每个方格的xy坐标
    CurrentAct.Items[I] := TPoint.Create(NewX, NewY);

  end;

  //默认可以移动
  Result := True;
end;


end.

