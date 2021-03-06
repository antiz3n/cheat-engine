unit DPIHelper;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, Buttons, Graphics, forms, StdCtrls;

procedure AdjustSpeedButtonSize(sb: TSpeedButton);
procedure AdjustComboboxSize(cb: TComboBox; canvas: TCanvas);
procedure AdjustEditBoxSize(editbox: TEdit; mintextwidth: integer);
function GetEditBoxMargins(editbox: TEdit): integer;

implementation

uses globals, win32proc;

function GetEditBoxMargins(editbox: TEdit): integer;
var m: dword;
begin
  if WindowsVersion>=wvVista then
    m:=sendmessage(editbox.Handle, EM_GETMARGINS, 0,0)
  else
    m:=10;

  result:=(m shr 16)+(m and $ffff);
end;

procedure AdjustEditBoxSize(editbox: TEdit; mintextwidth: integer);
var marginsize: integer;
begin
  marginsize:=GetEditBoxMargins(editbox);
  editbox.clientwidth:=mintextwidth+marginsize;
end;

procedure AdjustComboboxSize(cb: TComboBox; canvas: TCanvas);
var
  cbi: TComboboxInfo;
  i: integer;
  s: string;
  maxwidth: integer;

  w: integer;
begin
  maxwidth:=0;
  for i:=0 to cb.Items.Count-1 do
  begin
    s:=cb.Items[i];
    maxwidth:=max(maxwidth, Canvas.TextWidth(s));
  end;

  cbi.cbSize:=sizeof(cbi);
  if GetComboBoxInfo(cb.Handle, @cbi) then
  begin
    i:=maxwidth-(cbi.rcItem.Right-cbi.rcItem.Left)+4;

    w:=cb.width+i;
  end
  else
    w:=maxwidth+16;

  cb.width:=w;
  cb.Constraints.MinWidth:=w;
end;

procedure AdjustSpeedButtonSize(sb: TSpeedButton);
const
  designtimedpi=96;
//  designtimedpi=50;
var
  bm: TBitmap;
  ng: integer;
begin
  if (fontmultiplication>1.0) or (screen.PixelsPerInch<>designtimedpi) then
  begin
    sb.Transparent:=false;
    sb.Glyph.Transparent:=false;
    ng:=sb.NumGlyphs;

    bm:=TBitmap.Create;
    bm.Assign(sb.Glyph);

    if (screen.PixelsPerInch<>designtimedpi) then
    begin
      bm.width:=scalex(sb.Glyph.Width, designtimedpi);
      bm.height:=scaley(sb.Glyph.Height, designtimedpi);
    end
    else
    begin
      bm.width:=trunc(bm.width*fontmultiplication);
      bm.height:=trunc(bm.height*fontmultiplication);
    end;
    bm.Canvas.StretchDraw(rect(0,0, bm.width, bm.height),sb.Glyph);

    if (screen.PixelsPerInch<>designtimedpi) then
    begin
      sb.Width:=scalex(sb.Width, designtimedpi);
      sb.Height:=scaley(sb.Height, designtimedpi);
    end
    else
    begin
      sb.width:=trunc(sb.width*fontmultiplication);
      sb.height:=trunc(sb.height*fontmultiplication);
    end;
    bm.TransparentColor:=0;
    bm.TransparentMode:=tmAuto;

    sb.Glyph:=bm;
    sb.Glyph.Transparent:=true;
    sb.NumGlyphs:=ng;
    sb.Transparent:=true;
    bm.free;
  end;
end;

end.

