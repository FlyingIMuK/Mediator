unit fMediator;
(* Beim Dosimeter wird in 10s Abständen gemessen, im Biometer mit 5 min
  * Um die beiden Daten vergleichen zu können, müssen die Dosimeterwerte
  * auf 5 min gemittelt werden.
  * Die Dosimetermessungen kommen leider nicht gleichmäßig an, sondern
  * manchmal fehlen einzelne Werte
  * Das Programm füllt sie mit den Mittelwerten
*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Mask, Buttons, IniFiles,
  Menus, ComCtrls, DateUtils, ExtCtrls, JvToolEdit, JvExMask,
  ColorGrid;

type
  TxDespikeModus = (xTemp, xPress, xHum, xZero);

  TfrmMediator = class(TForm)
    Label1: TLabel;
    BitBtn1: TBitBtn;
    cgdWerte: TXColorGrid;
    PopupMenu1: TPopupMenu;
    menSetToZero: TMenuItem;
    menSetToValue: TMenuItem;
    bbnSave: TBitBtn;
    SaveDialog1: TSaveDialog;
    menVoidTemp: TMenuItem;
    menVoidHum: TMenuItem;
    menVoidRad: TMenuItem;
    menMEZ2UTC: TMenuItem;
    menDespikeTemp: TMenuItem;
    menPrecCorr: TMenuItem;
    menDespikePress: TMenuItem;
    menDespikeHum: TMenuItem;
    N1: TMenuItem;
    N11: TMenuItem;
    menRadiationCorr: TMenuItem;
    N2: TMenuItem;
    menDelLine: TMenuItem;
    sb1: TStatusBar;
    SpeedButton1: TSpeedButton;
    menDeZeroSpalte: TMenuItem;
    menSynthDiffRad: TMenuItem;
    btnLoad: TButton;
    cmbInterval: TComboBox;
    Label2: TLabel;
    deSource: TJvDirectoryEdit;
    feInput: TJvFilenameEdit;
    cmbFiletype: TComboBox;
    btnFillGaps: TButton;
    btnLoadFillGapSave: TButton;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure bbnSaveClick(Sender: TObject);
    (* procedure feInputAfterDialog(Sender: TObject; var Name: string;
      var Action: Boolean);
    *) procedure Openfile(sFN: string);
    procedure SaveFile(sFN: string);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Zeitrasterreduzieren1Click(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnFillGapsClick(Sender: TObject);
    procedure btnLoadFillGapSaveClick(Sender: TObject);
procedure Fillgaps;
  private
    fIn, fOut: Text;
    _iPos, _iError, _iFileNo: integer;
    _aValues: array of Extended;
    _aPrecision: array of integer;
    _slsFieldType: TStringList;

  public
    { Public-Deklarationen }
  end;

var
  frmMediator: TfrmMediator;
  sGlobFilename, sGlobExt, sGlobLogfile, sGlobDataDir, sGlobAktDir,
    sGlobIniFile: string;

implementation

uses fMsgWin, mGlobProc_B;

{$R *.dfm}
(* *************************************************************************** *)

procedure TfrmMediator.FormCreate(Sender: TObject);
var
  sExe, sName, sExtension: string;
  fIni: TIniFile;

begin
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.ShortDateFormat := 'dd.mm.yyyy';
  FormatSettings.ShortTimeFormat := 'hh:nn:ss';

  sExe := Application.ExeName;
  (* dDate := FileDateToDateTime(FileAge(sExe));

    Caption := 'Diogenes: "Geh mir aus der Sonne..."    ' +
    'Version ' + sVersionsInfo(sExe) +
    ' (' + DateTimeToStr(dDate) + ')'; *)

  AnalyseFileName(sExe, sGlobAktDir, sName, sExtension);

  sGlobIniFile := sGlobAktDir + '\' + sName + '.Ini';
  sGlobLogfile := sGlobAktDir + '\Logfile.txt';
  fIni := TIniFile.Create(sGlobIniFile);
  with fIni do
  begin
    feInput.Text := ReadString('Mediator', 'InputFile', 'c:\');
    feInput.InitialDir := ReadString('Mediator', 'InputDir', 'c:\');
    deSource.Text := ReadString('Mediator', 'SourceDir', 'c:\');
    deSource.InitialDir := deSource.Text;
    // fpm1.RestoreFormPlacement;
    free;
  end;
  _slsFieldType := TStringList.Create;

end;

(* *************************************************************************** *)

procedure TfrmMediator.bbnSaveClick(Sender: TObject);
var sDir, sFN, sExt:string;
begin
  SaveDialog1.InitialDir := sGlobDataDir;
  AnalyseFileName(feInput.FileName,sDir,sFN,sExt);
  SaveDialog1.FileName := sDir+'\'+sFN+'_1.'+sExt;
  if SaveDialog1.Execute then
    if FileExists(SaveDialog1.FileName) then
      if MessageDlg('File exists! Overwrite?', mtConfirmation, [mbYes, mbNo], 0)
        = mrNo then
        exit;

  SaveFile(SaveDialog1.FileName);
end;

(* *************************************************************************** *)

procedure TfrmMediator.Openfile(sFN: string);
// Das Schema DateTime; Float;Float;Float... muss eingehalten werden
var
  sPath, sExt, sLine, sLine1, sOldLine, s1, sDatum: string;
  i, iLineCount, iCount, iC, iR, iMin, iOldMin, iTimeCol, iDataCol, iNumCount,
    iInterval, iNextMin, iLineNo, iDateTimePos, iNumberOfGaps, iPos: integer;
  iSum, iUVSum: Longint;
  fSum, fUVSum, fDate: Extended;
  dFirstdate, dLastDate, dTime, dNextInterval, dDiff: TDateTime;
  fIni: TIniFile;
  cDelimiter: char;
  bOK: boolean;
begin
  iNumberOfGaps := 0;
  dFirstdate := NullDate;

  iDateTimePos := BADINDEX;
  case cmbInterval.ItemIndex of
    0:
      iInterval := 10;
  end;
  // iInterval := StrToInt(cmbInterval.text);
  Assignfile(fIn, sFN);
  reset(fIn);
  readln(fIn, sLine); // erste Zeile ist Legende
  // Trenner analysieren
  if pos(';', sLine) <> 0 then
    cDelimiter := ';';
  if pos(scTab, sLine) <> 0 then
    cDelimiter := scTab;

  AnalyseFileName(sFN, sGlobDataDir, sGlobFilename, sGlobExt);
  fIni := TIniFile.Create(sGlobIniFile);
  with fIni do
  begin
    WriteString('Mediator', 'InputDir', sGlobDataDir);
    free;
  end;
  _slsFieldType.Clear;
  if _iFileNo = 1 then
  begin
    cgdWerte.ClearGrid;
    cgdWerte.ColCount := 2;
    cgdWerte.RowCount := 2;
    cgdWerte.ColWidths[0] := 140;
    cgdWerte.ColWidths[1] := 120;

    iC := 0;
    while sLine <> '' do
    begin
      cgdWerte.Cells[iC, 0] := sToken(sLine, [cDelimiter], true);
      inc(iC);
      cgdWerte.ColCount := cgdWerte.ColCount + 1;
    end;

    cgdWerte.ColCount := cgdWerte.ColCount - 2;
    cgdWerte.RowCount := 2;
  end;

  readln(fIn, sLine); // zweite Zeile analysieren

  // Analysiere den Typ der Spalten
  sLine1 := sLine;
  iC := 0;
  while sLine1 <> '' do
  begin
    s1 := sToken(sLine1, [cDelimiter], true);
    // cgdWerte.Cells[iC, 2] := s1;
    if lStrIsInt(s1) then
    begin
      _slsFieldType.add('Integer');
    end
    else if lStrIsExtended(s1) then
    begin
      _slsFieldType.add('Extended');
      // cgdWerte.Cells[iC, 1] := 'Extended';
    end
    else if lStrIsDate(s1) then
      cgdWerte.Cells[iC, 1] := 'Date'
    else if lStrIsDateTime(s1) then
    begin
      // cgdWerte.Cells[iC, 1] := 'Date/Time';
      _slsFieldType.add('Date/Time');
    end
    else
    begin
      // cgdWerte.Cells[iC, 1] := 'Text';
      _slsFieldType.add('Text');
    end;
    // if not (lStrIsExtended(s1) or lStrIsDate(s1) or lStrIsDateTime(s1)) then

    // slsLegende.Delete(iC);
    inc(iC);
  end;
  // showmessage(intToStr(iC));
  SetLength(_aPrecision, iC);

  sLine1 := sLine;
  iLineNo := 1;
  iR := 0;
  reset(fIn);
  readln(fIn); // erste zeile verwerfen

  while not EOF(fIn) do
  begin
    readln(fIn, sLine1); // nächste Zeile analysieren

    iC := 0;
    cgdWerte.RowCount := cgdWerte.RowCount + 1;
    inc(iR);

    while sLine1 <> '' do
    begin
      s1 := sToken(sLine1, [cDelimiter], true);
      if _slsFieldType[iC] = 'Date/Time' then
      begin
        _aPrecision[iC] := 0;
        if lStrIsDateTime(s1) then
        begin
          dTime := StrToDateTime(s1);
          if dFirstdate = NullDate then
          begin
            dFirstdate := dTime;
            cgdWerte.Cells[iC, iR] := FormatdateTime('dd.mm.yyyy hh:nn:ss',
              dFirstdate);
            // dLastDate := dFirstdate;
          end

          else
          begin
            dDiff := dTime - dLastDate - 10 / (24 * 3600);
            while (dDiff > 0.0001) do
            begin
              inc(iNumberOfGaps);
              // erst mal fest => Zeile fehlt
              dLastDate := dLastDate + 10 / (24 * 3600);
              cgdWerte.Cells[iC, iR] := FormatdateTime('dd.mm.yyyy hh:nn:ss',
                dLastDate);
              cgdWerte.RowColor[iR] := clRed;
              cgdWerte.RowCount := cgdWerte.RowCount + 1;
              inc(iR);

              dDiff := dTime - dLastDate - 10 / (24 * 3600);

            end;

            cgdWerte.Cells[iC, iR] :=
              FormatdateTime('dd.mm.yyyy hh:nn:ss', dTime);
          end;
          dLastDate := dTime;

        end
        else
          dTime := NoFloat;

        // showmessage(FormatDateTime('hh:nn:ss', dTime));

      end;
      if _slsFieldType[iC] = 'Integer' then
      begin
        cgdWerte.Cells[iC, iR] := s1;
        _aPrecision[iC] := 0;
      end;
      if _slsFieldType[iC] = 'Extended' then
      begin
        cgdWerte.Cells[iC, iR] := s1;
        sToken(s1, ['.'], true);
        _aPrecision[iC] := length(s1);
      end;

      inc(iC);
    end;
    sb1.Panels[0].Text := 'Number Of Gaps: ' + intTostr(iNumberOfGaps);
    {
      if dTime < 0 then break;
      iMin := MinuteOf(dTime);
      if iMin mod iInterval = 0 then begin
      cgdWerte.RowCount := cgdWerte.RowCount + 1;
      cgdWerte.cells[0, cgdWerte.RowCount - 2] := FormatDateTime('dd.mm.yyyy hh:nn:ss', dTime);
      for iC := 0 to cgdWerte.colcount - 2 do
      if slsLegende[iC] = 'Extended' then begin
      cgdWerte.cells[iC, cgdWerte.RowCount - 2] := FloatToStr(aValues[iC] / iLineNo);
      aValues[iC] := 0;
      end;
      iLineNo := 0;

      end;
    }
    inc(iLineNo);
  end;

  {

    slsLegende.free;
    cgdWerte.ColCount := slsLegende.Count + 1;

    for i := 1 to slsLegende.Count - 1 do
    cgdWerte.Cells[i, 0] := slsLegende[i - 1];


    // in welcher spalte steht die Zeit
    iTimeCol := 0;

    repeat
    inc(iTimeCol);
    sDatum := sToken(sLine, [cDelimiter], true);
    //   if lStrIsDateTime(sDatum) then showmessage('Date');

    try
    dTime := StrToDateTime(sDatum);
    //      showmessage(FormatDateTime('hh:nn:ss',dTime));
    //    showmessage(FloatToStr(dTime);
    //    showmessage(IntToStr(minuteof(dTime)));
    iOldMin := minuteof(dTime) + 60 * HourOf(dTime);
    i := trunc(minuteof(dTime) / iInterval) + 1;
    iNextMin := i * iInterval + 60 * HourOf(dTime);
    //      Showmessage(IntToStr(iOldMin)+ '  '+IntToStr(iNextMin));
    dNextInterval := trunc(dTime) + iNextMin / (24 * 60);
    //   showmessage(FormatDateTime('dd.mm.yyyy hh:nn:ss',dNextInterval));
    bOK := true;
    except
    end;
    until bOK;
    iNumCount := 0; // so viele Spalten gibt es
    while sLine <> '' do begin
    s1 := stoken(sLine, [cDelimiter], true); // datum weg
    if lStrIsExtended(s1) then inc(iNumCount);
    end;
    //   ShowMessage(IntToStr(iNumCount));
    SetLength(aValues, iNumCount);

    // jettzt gehts los
    reset(fIn);
    readln(fIn, sLine); // erste Zeile ist Legende
    iLineCount := 0;
    while not eof(fIn) do begin
    readln(fIn, sLine);
    i := 1;
    while i < iTimeCol do begin
    stoken(sLine, [cDelimiter], true); // ggf Laufnummern weg
    inc(i);
    end;
    sDatum := sToken(sLine, [cDelimiter], true);
    dTime := StrToDateTime(sDatum);
    //     showmessage(FloatToStr(dTime));

    iC := 1;

    //   iMin := minuteof(dTime) + 60 * HourOf(dTime);
    fDate := trunc(dTime);

    // Falls eine neue Minute anbricht => alte wegschreiben

    //   if iMin <> iOldMin then begin
    if dTime > dNextInterval then begin
    if iCount > 0 then begin

    //    dTime := iMin / (24 * 60) + fDate;
    if dNextInterval <= 1.0 then
    sDatum := FormatDateTime('hh:nn:ss', dNextInterval)
    else
    sDatum := FormatDateTime('dd.mm.yyyy hh:nn:ss', dNextInterval);
    cgdWerte.RowCount := cgdWerte.RowCount + 1;
    iR := cgdWerte.RowCount - 2;
    cgdWerte.Cells[0, iR] := IntToStr(iR);
    cgdWerte.Cells[1, iR] := sDatum;
    for i := 0 to iNumCount - 1 do begin
    aValues[i] := aValues[i] / iCount;
    cgdWerte.Cells[i + 2, iR] := FloatToStr(aValues[i]);
    aValues[i] := 0;
    end;
    iCount := 0;
  }

  { //fSum := iSum / iCount;
    //fUVSum := iUVSum / iCount;
    iC := 1;
    inc(iR);
    if iR > 1 then
    cgdWerte.RowCount := cgdWerte.RowCount + 1;
    cgdWerte.Cells[0, iR] := IntToStr(cgdWerte.RowCount - 1);
    while sLine <> '' do begin
    case iC of
    1: begin end;
    12: begin
    cgdWerte.Cells[iC, iR] := Format('%.0f', [fSum]);
    sToken(sLine, [';'], true);
    end;

    17: begin
    cgdWerte.Cells[iC, iR] := Format('%.0f', [fUVSum]);
    sToken(sLine, [';'], true);
    end;
    else cgdWerte.Cells[iC, iR] := sToken(sLine, [cDelimiter], true);
    end;
    inc(iC);

    end;
  }{
    end;
    i := trunc(minuteof(dTime) / iInterval) + 1;
    iNextMin := i * iInterval + 60 * HourOf(dTime);
    dNextInterval := fDate + iNextMin / (24 * 60);

    //    iOldMin := iMin;
    end;


    (*     for i := 1 to 9 do sToken(sLine1, [cDelimiter], true);

    iSum := iSum + StrToIntDef(sToken(sLine1, [cDelimiter], true), 0);
    for i := 1 to 3 do sToken(sLine1, [cDelimiter], true);
    iUVSum := iUVSum + StrToIntDef(sToken(sLine1, [cDelimiter], true), 0);
    *)

    iDataCol := 0;
    while sLine <> '' do begin
    s1 := sToken(sLine, [cDelimiter], true);
    if lStrIsExtended(s1) then begin
    aValues[iDataCol] := aValues[iDataCol] + StrToFloatDef(s1, 0);
    inc(iDataCol);
    end;
    end;


    inc(iCount);
    inc(iLineCount);
    sb1.Panels[0].Text := IntTOstr(iLineCount);
    end;
  }

  // finally
  closefile(fIn);
  // bbnSave.Enabled := true;
  // cgdWerte.RowCount := cgdWerte.RowCount - 1;

end;

(* *************************************************************************** *)

procedure TfrmMediator.SaveFile(sFN: string);
var
  sLine, s1: string;
  iC, iR: integer;
begin
  cgdWerte.bWriteToCSV(sFN, true);

  {
    with cgdWerte do begin

    // 1. Zeile Legende
    //            Datum/Zeit; Temp 00;  Uoc 00;Shunt 00;   SE45T;   SE45I;   SW45T;   SW45I

    sLine := Format('%19s;', [cells[1, 0]]);
    for iC := 2 to colcount - 1 do begin
    s1 := Format('%8s;', [cells[iC, 0]]);
    sLine := sLine + s1;
    end;
    delete(sLine, length(sLine), 1); // letztes ';' weg
    writeln(fOut, sLine);

    // jetzt die Werte
    for iR := 1 to rowcount - 1 do begin
    sLine := '';
    for iC := 1 to colcount - 1 do begin
    s1 := Format('%8s', [cells[iC, iR]]);
    sLine := sLine + s1 + ';';
    end;
    delete(sLine, length(sLine), 1);
    writeln(fOut, sLine);
    end;


    end;
    closeFile(fOut);
  }
end;

(* *************************************************************************** *)

procedure TfrmMediator.FormClose(Sender: TObject; var Action: TCloseAction);
var
  fIni: TIniFile;
begin
  fIni := TIniFile.Create(sGlobIniFile);
  with fIni do
  begin
    WriteString('Mediator', 'InputFile', feInput.Text);
    WriteString('Mediator', 'InputDir', feInput.InitialDir);
    WriteString('Mediator', 'SourceDir', deSource.Text);

    free;
  end;
end;

(* ************************************************************************* *)

procedure TfrmMediator.Zeitrasterreduzieren1Click(Sender: TObject);
(* z.B. Rohdaten im Minutenraster auf 5-minutenraster bringen *)
var
  i, iCol, iRow, iInc, iIncMax: integer;
  fValue, fValueIntegral: Extended;
begin
  // erst Mitteln
  with cgdWerte do
  begin
    for iCol := 2 to ColCount do
    begin
      fValueIntegral := 0;
      for iRow := 2 to RowCount do
      begin
        fValue := StrToFloatDef(Cells[iCol, iRow], NoFloat);
        if fValue > NoFloat then
          fValueIntegral := fValueIntegral + fValue;
        if (iRow - 1) mod 5 = 0 then
        begin
          cellcolor[iCol, iRow] := clRed;
          Cells[iCol, iRow] := Format('%.2f', [fValueIntegral / 5]);
          fValueIntegral := 0;

        end;
      end;
    end;
  end;
  // alle dazwischenliegenden Zeilen werden gelöscht
  iIncMax := 5; // alle 5 Minuten
  with cgdWerte do
  begin
    iRow := 2; // Offset = 0
    repeat
      for i := 1 to 4 do
      begin
        cgdWerte.DeleteRow(iRow);
      end;
      inc(iRow);
      // inc(iRow);
    until iRow >= RowCount;
  end;

end;

(* ************************************************************************* *)

procedure TfrmMediator.btnFillGapsClick(Sender: TObject);
 Begin
   FillGaps;
 End;


(* ************************************************************************* *)
Procedure TfrmMediator.FillGaps;
var
  iC, iR: integer;
  fLastvalid, fFirstValid, fDiff: Extended;
begin
  for iC := 1 to cgdWerte.ColCount - 1 do
  begin
    iR := 1;
    while iR < cgdWerte.RowCount - 1 do
    begin
      if cgdWerte.Cells[iC, iR] = '' then
      begin
        inc(iR);
        // while cgdWerte.Cells[iC,iR]<>'' do
        // inc(iR);
        fFirstValid := StrToFloatDef(cgdWerte.Cells[iC, iR], NoFloat);
        fDiff := (fFirstValid - fLastvalid) / 2;
        cgdWerte.Cells[iC, iR - 1] := FloatToStrF(fLastvalid + fDiff, ffFixed,
          8, _aPrecision[iC]);

        // cgdWerte.Cells[iC, iR] := 'Gap'
      end;
      fLastvalid := StrToFloatDef(cgdWerte.Cells[iC, iR], NoFloat);
      inc(iR);
    end

  end;
end;

(* ************************************************************************* *)

procedure TfrmMediator.btnLoadClick(Sender: TObject);

begin
 _iFileNo := 1;

  Openfile(feInput.FileName);
end;

procedure TfrmMediator.btnLoadFillGapSaveClick(Sender: TObject);

var
  sr: TSearchRec;
  s,sPath,sFN,sExt: string;

begin
  _iFileNo := 1;
  // Filename einlesen
  if FindFirst(deSource.Text + '\*UV.*', faAnyfile, sr) = 0 then
    repeat
      s := sr.Name;
      AnalyseFileName(s,sPath,sFN,sExt);

      if s[1] <> '.' then
      begin
        Openfile(deSource.Text + '\' + s);
        inc(_iFileNo);
        Application.ProcessMessages;
        Fillgaps;
        Application.ProcessMessages;
        SaveFile(deSource.Text+'\'+sFN+'_1.CSV');

      end;
    until FindNext(sr) <> 0;

  FindClose(sr);
  sb1.Panels[0].Text:='Conversion finished'
  end;

end.
