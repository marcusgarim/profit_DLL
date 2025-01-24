unit frmClientU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.ComCtrls, Vcl.Samples.Spin, DateUtils, enums, System.Generics.Collections,
  System.ImageList, Vcl.ImgList, TypInfo, structs;

type
  TType = (tROT, tMD, tConfig);

  TfrmClient = class(TForm)
    pnlLeft: TPanel;
    pnlRight: TPanel;
    edtUser: TEdit;
    edtPass: TEdit;
    edtActCode: TEdit;
    lbPass: TLabel;
    lbActCode: TLabel;
    lbUser: TLabel;
    lbLogin: TLabel;
    btnInitialize: TButton;
    lbStatus: TLabel;
    imgInfoOff: TImage;
    imgMdOff: TImage;
    imgRotOff: TImage;
    btnFinalize: TButton;
    lbLoginResult: TLabel;
    lbVersion: TLabel;
    cbFunctions: TComboBox;
    pnlFunc: TPanel;
    lbFunc: TLabel;
    btnExecute: TButton;
    pcType: TPageControl;
    pnlPC: TPanel;
    tabRot: TTabSheet;
    tabMd: TTabSheet;
    edtTickerMd: TEdit;
    cbBolsaMd: TComboBox;
    lbBolsaMd: TLabel;
    lbTickerMd: TLabel;
    mmUpdates: TMemo;
    lbCallbackTitle: TLabel;
    lbAgentIdMd: TLabel;
    edtAgentId: TSpinEdit;
    lbContaRot: TLabel;
    lbBrokerIdRot: TLabel;
    edtBrokerAccRot: TEdit;
    edtBrokerIdRot: TEdit;
    lbPassRot: TLabel;
    edtPassRot: TEdit;
    lbTickerRot: TLabel;
    lbBolsaRot: TLabel;
    edtTickerRot: TEdit;
    cbBolsaRot: TComboBox;
    edtPriceRot: TEdit;
    lbPriceRot: TLabel;
    lbAmountRot: TLabel;
    edtAmountRot: TEdit;
    lbTitleRot: TLabel;
    lbTitleMd: TLabel;
    edtPriceStopRot: TEdit;
    lbPriceStopRot: TLabel;
    edtClOrdIdRot: TEdit;
    lbClOrdIdRot: TLabel;
    bvRot: TBevel;
    dateStartRot: TDateTimePicker;
    dateEndRot: TDateTimePicker;
    lbDateStartRot: TLabel;
    lbDateEndRot: TLabel;
    lbProfitIdRot: TLabel;
    edtProfitIdRot: TEdit;
    bvMd: TBevel;
    dateStartMd: TDateTimePicker;
    lbDateStartMd: TLabel;
    dateEndMd: TDateTimePicker;
    lbDateEndMd: TLabel;
    lbTimeStartMd: TLabel;
    timeStartMd: TDateTimePicker;
    lbTimeEndMd: TLabel;
    timeEndMd: TDateTimePicker;
    tabConfig: TTabSheet;
    lbTitleCfg: TLabel;
    mmDescCfg: TMemo;
    bvCfg: TBevel;
    imgCfg: TImage;
    mmFunc: TMemo;
    lbFuncTitle: TLabel;
    imgList: TImageList;
    btnClearUpdates: TButton;
    imgInfoOn: TImage;
    imgMdOn: TImage;
    imgRotOn: TImage;
    edtBookPos: TEdit;
    mmBookPos: TMemo;
    btnBookPos: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnInitializeClick(Sender: TObject);
    procedure btnFinalizeClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure cbFunctionsChange(Sender: TObject);
    procedure btnClearUpdatesClick(Sender: TObject);
    procedure btnBookPosClick(Sender: TObject);
  private
    FConnected: Boolean;
    FConnection: TDictionary<TConnStateType, Integer>;
    FListBuyPriceBook: TList;
    FListSellPriceBook: TList;
    FListBuyOfferBook: TList;
    FListSellOfferBook: TList;
    procedure LoadDllVersion;
    procedure FillComboFunctions;
    procedure ServerClock(AText: String);
    procedure LastDailyClose(AText: String);
    procedure CopyMemoryToString(var ADest: String; Source: Pointer; Length: NativeUInt);
    function DecryptArrayPosition(AData: Pointer): String;
    procedure EnableDisableControls(ATab: TTabSheet; AItem: String);
    procedure ConnectionNotify(Sender: TObject; const Item: Integer; Action: TCollectionNotification);
    procedure LoadImages;
    procedure DecryptPriceArray(ASource: Pointer; ATarget: TList);
    procedure DecryptOfferArray(ASouce: Pointer; ATarget: TList);

    procedure DecryptPriceArrayV2(ASource: Pointer; ATarget: TList);
    procedure DecryptOfferArrayV2(ASouce: Pointer; ATarget: TList);

  public
    property Connected: Boolean read FConnected write FConnected;
    property Connection: TDictionary<TConnStateType, Integer> read FConnection write FConnection;
    property ListBuyPriceBook: TList read FListBuyPriceBook write FListBuyPriceBook;
    property ListSellPriceBook: TList read FListSellPriceBook write FListSellPriceBook;
    property ListBuyOfferBook: TList read FListBuyOfferBook write FListBuyOfferBook;
    property ListSellOfferBook: TList read FListSellOfferBook write FListSellOfferBook;

    destructor Destroy; override;
  end;

    procedure UpdateConnStatus(AType, AValue: Integer);
    procedure GenericLogUpdate(AValue: String);
    procedure UpdatePriceBook(                                nVersion : Integer;
                                                              rAssetID : TAssetIDRec ;
                              nAction , nPosition, Side, nQtds, nCount : Integer;
                                                                sPrice : Double;
                                                 pArraySell, pArrayBuy : Pointer);

    procedure UpdateOfferBook(                                            nVersion : Integer;
                                                                          rAssetID : TAssetIDRec ;
                                            nAction, nPosition, Side, nQtd, nAgent : Integer;
                                                                          nOfferID : Int64;
                                                                            sPrice : Double;
                              bHasPrice, bHasQtd, bHasDate, bHasOfferID, bHasAgent : Char;
                                                                          pwcDate  : PWideChar;
                                                             pArraySell, pArrayBuy : Pointer);

var
  frmClient: TfrmClient;

const
  C_CURRENTVER = '4.0.0.0';

implementation

uses
  functionWrapperU, callbackWrapperU;

{$R *.dfm}

procedure TfrmClient.FormCreate(Sender: TObject);
begin
  {$IFDEF DEBUG}
    //edtUser.Text:= 'user@user.com';
    //edtPass.Text:= 'pass';
    //edtActCode.Text:= 'actCode';
    //SetServerAndPortRoteamento(nil, nil); // hades funcionario
  {$ENDIF}

  lbFunc.Caption:= 'Funções ' + '(' + C_CURRENTVER + ')';

  LoadDllVersion;

  FillComboFunctions;

  Self.Connected:= False;

  dateStartRot.Date:= Now;
  dateEndRot.Date  := Now;
  dateStartMd.Date := Now;
  timeStartMd.Time := Now;
  dateEndMd.Date   := Now;
  timeEndMd.Time   := Now;

  Self.Connection:= TDictionary<TConnStateType, Integer>.Create;
  Self.Connection.Clear;
  Self.Connection.OnValueNotify:= Self.ConnectionNotify;

  LoadImages;

  ListBuyPriceBook := TList.Create;
  ListSellPriceBook:= TList.Create;
  ListBuyOfferBook := TList.Create;
  ListSellOfferBook:= TList.Create;
end;

procedure TfrmClient.btnInitializeClick(Sender: TObject);
var
  nRes: ShortInt;
begin
  {nRes:=  DLLInitializeMarketLogin(PWideChar(edtActCode.Text),
                           PWideChar(edtUser.Text),
                           PWideChar(edtPass.Text),
                           StateCallback,
                           NewTradeCallback,
                           NewDailyCallback,
                           PriceBookCallback,
                           OfferBookCallback,
                           HistoryTradeCallback,
                           ProgressCallback,
                           TinyBookCallback);}
  nRes:=  DLLInitializeLogin(PWideChar(edtActCode.Text),
                             PWideChar(edtUser.Text),
                             PWideChar(edtPass.Text),
                             StateCallback,
                             HistoryCallback,
                             OrderChangeCallback,
                             AccountCallback,
                             NewTradeCallback,
                             NewDailyCallback,
                             nil,
                             nil,
                             HistoryTradeCallback,
                             ProgressCallback,
                             TinyBookCallback);

  lbLoginResult.Caption:= 'Initialize return: ' + IntToStr(nRes);
  lbLoginResult.Visible:= true;

  if nRes <> NL_OK then
    ShowMessage('Erro durante inicialização.')
  else
  begin
    SetEnabledHistOrder(1);
    SetAssetListCallback(AssetListCallback);
    SetAssetListInfoCallback(AssetListInfoCallback);
    SetAssetListInfoCallbackV2(AssetListInfoCallbackV2);
    SetChangeStateTickerCallback(ChangeStateTickerCallback);
    SetAdjustHistoryCallback(AdjustHistoryCallback);
    SetAdjustHistoryCallbackV2(AdjustHistoryCallbackV2);
    SetTheoreticalPriceCallback(TheoreticalPriceCallback);
    SetChangeCotationCallback(ChangeCotationCallback);
    SetHistoryCallbackV2(HistoryCallbackV2);
    SetOrderChangeCallbackV2(OrderChangeCallbackV2);
    SetOfferBookCallbackV2(OfferBookCallbackV2);
    SetPriceBookCallbackV2(PriceBookCallbackV2);
  end;
end;

procedure TfrmClient.btnFinalizeClick(Sender: TObject);
begin
  DLLFinalize;
end;

procedure TfrmClient.LoadDllVersion;
var
  sExe, sVer: string;
  iSize: integer;
  hHandle: Cardinal;
  pBuff: Pointer;
 FixedFileInfo : PVSFixedFileInfo;
begin
{$IFDEF CPUX64}
  sExe:= ExtractFilePath(Application.ExeName) + 'ProfitDLL64.dll';
{$ELSE}
  sExe:= ExtractFilePath(Application.ExeName) + 'ProfitDLL.dll';
{$ENDIF}
  iSize:= GetFileVersionInfoSize(PWideChar(sExe), hHandle);
  GetMem(pBuff, iSize);
  try
    if GetFileVersionInfo(PWideChar(sExe), hHandle, iSize, pBuff) then
    begin
      VerQueryValue(pBuff, PWideChar('\'), Pointer(FixedFileInfo), DWord(iSize));
      sVer := IntToStr(FixedFileInfo.dwFileVersionMS div $10000) + '.' +
                  IntToStr(FixedFileInfo.dwFileVersionMS and $0FFFF) + '.' +
                  IntToStr(FixedFileInfo.dwFileVersionLS div $10000) + '.' +
                  IntToStr(FixedFileInfo.dwFileVersionLS and $0FFFF);

      lbVersion.Caption:= lbVersion.Caption + ' ' + sVer;
    end;
    if sVer <> C_CURRENTVER then
    begin
      lbVersion.Font.Color:= clMaroon;
      {$IFNDEF DEBUG}
      ShowMessage('Versão compilada diferente da versão encontrada da DLL.' + #13 +
                  'Algumas funções podem não funcionar conforme o esperado.');
      {$ENDIF}
    end;
  finally
    FreeMem(pBuff);
  end;

end;

procedure UpdateConnStatus(AType, AValue: Integer);
label
  login, md, rot, act;
begin
  case TConnStateType(AType) of
    cstInfo: goto login;
    cstMarketData: goto md;
    cstRoteamento: goto rot;
    cstActivation: goto act;
  end;

  login:
    GenericLogUpdate(Format('StateCallback: %s | %s', [GetEnumName(TypeInfo(TConnStateType), AType),
                                                       GetEnumName(TypeInfo(TConnInfo), AValue)]));
    if (AValue = Ord(ciArSuccess)) then
      frmClient.Connection.AddOrSetValue(cstInfo, 1)
    else
      frmClient.Connection.AddOrSetValue(cstInfo, 0);
    exit;

  md:
    GenericLogUpdate(Format('StateCallback: %s | %s', [GetEnumName(TypeInfo(TConnStateType), AType),
                                                       GetEnumName(TypeInfo(TConnMarketData), AValue)]));
    if (AValue = Ord(cmdConnectedLogged)) then
      frmClient.Connection.AddOrSetValue(cstMarketData, 1)
    else
      frmClient.Connection.AddOrSetValue(cstMarketData, 0);
    exit;

  rot:
    GenericLogUpdate(Format('StateCallback: %s | %s', [GetEnumName(TypeInfo(TConnStateType), AType),
                                                       GetEnumName(TypeInfo(TConnRoteamento), AValue)]));
    if (AValue = Ord(crConnected)) or (AValue = Ord(crBrokerConnected)) then
      frmClient.Connection.AddOrSetValue(cstRoteamento, 1)
    else
      frmClient.Connection.AddOrSetValue(cstRoteamento, 0);
    exit;

  act:
    GenericLogUpdate(Format('StateCallback: %s | %s', [GetEnumName(TypeInfo(TConnStateType), AType),
                                                       GetEnumName(TypeInfo(TConnActivation), AValue)]));
    if (AValue = Ord(caValid)) then
      frmClient.Connection.AddOrSetValue(cstActivation, 1)
    else if AValue = Ord(caInvalid) then
      frmClient.Connection.AddOrSetValue(cstActivation, 0);
    exit;
end;

procedure TfrmClient.FillComboFunctions;
begin
  // todas funções da DLL - adicionar no fim do combo //

  cbFunctions.Items.BeginUpdate;
  try
    with cbFunctions.Items do
    begin
      Clear;
      AddObject('SubscribeTicker',              TObject(tMD));
      AddObject('UnsubscribeTicker',            TObject(tMD));
      AddObject('SubscribePriceBook',           TObject(tMD));
      AddObject('UnsubscribePriceBook',         TObject(tMD));
      AddObject('SubscribeOfferBook',           TObject(tMD));
      AddObject('UnsubscribeOfferBook',         TObject(tMD));
      AddObject('GetAgentNameByID',             TObject(tMD));
      AddObject('GetAgentShortNameByID',        TObject(tMD));
      AddObject('SendBuyOrder',                 TObject(tROT));
      AddObject('SendSellOrder',                TObject(tROT));
      AddObject('SendStopBuyOrder',             TObject(tROT));
      AddObject('SendStopSellOrder',            TObject(tROT));
      AddObject('SendChangeOrder',              TObject(tROT));
      AddObject('SendCancelOrder',              TObject(tROT));
      AddObject('SendCancelOrders',             TObject(tROT));
      AddObject('SendCancelAllOrders',          TObject(tROT));
      AddObject('SendZeroPosition',             TObject(tROT));
      AddObject('GetAccount',                   TObject(tROT));
      AddObject('GetOrders',                    TObject(tROT));
      AddObject('GetOrder',                     TObject(tROT));
      AddObject('GetOrderProfitID',             TObject(tROT));
      AddObject('GetPosition',                  TObject(tROT));
      AddObject('GetHistoryTrades',             TObject(tMD));
      AddObject('GetSerieHistory',              TObject(tMD));
      AddObject('SetDayTrade',                  TObject(tConfig));
      AddObject('SetChangeCotationCallback',    TObject(tConfig));
      AddObject('SetAssetListCallback',         TObject(tConfig));
      AddObject('SetAssetListInfoCallback',     TObject(tConfig));
      AddObject('SetAssetListInfoCallbackV2',   TObject(tConfig));
      AddObject('SetEnabledLogToDebug',         TObject(tConfig));
      AddObject('RequestTickerInfo',            TObject(tMD));
      AddObject('SetChangeStateTickerCallback', TObject(tConfig));
      AddObject('SetEnabledHistOrder',          TObject(tConfig));
      AddObject('SubscribeAdjustHistory',       TObject(tMD));
      AddObject('UnsubscribeAdjustHistory',     TObject(tMD));
      AddObject('SetAdjustHistoryCallback',     TObject(tConfig));
      AddObject('SetAdjustHistoryCallbackV2',   TObject(tConfig));
      AddObject('SetTheoreticalPriceCallback',  TObject(tConfig));
      AddObject('SetServerAndPort',             TObject(tConfig));
      AddObject('GetServerClock',               TObject(tMD));
      AddObject('GetLastDailyClose',            TObject(tMD));
      AddObject('SendMarketSellOrder',          TObject(tROT));
      AddObject('SendMarketBuyOrder',           TObject(tROT));
      AddObject('SendZeroPositionAtMarket',     TObject(tROT));
      AddObject('SetHistoryCallbackV2',         TObject(tConfig));
      AddObject('SetOrderChangeCallbackV2',     TObject(tConfig));
    end;
  finally
    cbFunctions.Items.EndUpdate;
    cbFunctions.ItemIndex:= 0;
    cbFunctions.OnChange(nil);
  end;
end;

procedure TfrmClient.btnExecuteClick(Sender: TObject);
var
  sText: String;
  nRes: Int64;
  sRes: String;
  pRes: Pointer;
begin
  // executa cada funcao da dll //

  sText:= cbFunctions.Items.Strings[cbFunctions.ItemIndex];
  if cbFunctions.ItemIndex <> -1 then
  begin
    nRes:= -1;
    sRes:= EmptyStr;
    pRes:= nil;
    mmFunc.Lines.Clear;

    if sText = 'SubscribeTicker' then
      nRes:= SubscribeTicker(PWideChar(edtTickerMd.Text),PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]))
    else if sText = 'UnsubscribeTicker' then
      nRes:= UnsubscribeTicker(PWideChar(edtTickerMd.Text),PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]))
    else if sText = 'SubscribePriceBook' then
      nRes:= SubscribePriceBook(PWideChar(edtTickerMd.Text),PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]))
    else if sText = 'UnsubscribePriceBook' then
      nRes:= UnsubscribePriceBook(PWideChar(edtTickerMd.Text),PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]))
    else if sText = 'SubscribeOfferBook' then
      nRes:= SubscribeOfferBook(PWideChar(edtTickerMd.Text),PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]))
    else if sText = 'UnsubscribeOfferBook' then
      nRes:= UnsubscribeOfferBook(PWideChar(edtTickerMd.Text),PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]))
    else if sText = 'GetAgentNameByID' then
      sRes:= GetAgentNameByID(edtAgentId.Value)
    else if sText = 'GetAgentShortNameByID' then
      sRes:= GetAgentShortNameByID(edtAgentId.Value)
    else if sText = 'SendBuyOrder' then
      nRes:= SendBuyOrder(PWideChar(edtBrokerAccRot.Text),PWideChar(edtBrokerIdRot.Text),
                   PWideChar(edtPassRot.Text), PWideChar(edtTickerRot.Text),
                   PWideChar(cbBolsaRot.Items.Strings[cbBolsaRot.ItemIndex]),
                   StrToFloat(edtPriceRot.Text), StrToInt(edtAmountRot.Text))
    else if sText = 'SendSellOrder' then
      nRes:= SendSellOrder(PWideChar(edtBrokerAccRot.Text),PWideChar(edtBrokerIdRot.Text),
                   PWideChar(edtPassRot.Text), PWideChar(edtTickerRot.Text),
                   PWideChar(cbBolsaRot.Items.Strings[cbBolsaRot.ItemIndex]),
                   StrToFloat(edtPriceRot.Text), StrToInt(edtAmountRot.Text))
    else if sText = 'SendStopBuyOrder' then
      nRes:= SendStopBuyOrder(PWideChar(edtBrokerAccRot.Text),PWideChar(edtBrokerIdRot.Text),
                       PWideChar(edtPassRot.Text), PWideChar(edtTickerRot.Text),
                       PWideChar(cbBolsaRot.Items.Strings[cbBolsaRot.ItemIndex]),
                       StrToFloat(edtPriceRot.Text), StrToFloat(edtPriceStopRot.Text),
                       StrToInt(edtAmountRot.Text))
    else if sText = 'SendStopSellOrder' then
      nRes:= SendStopSellOrder(PWideChar(edtBrokerAccRot.Text),PWideChar(edtBrokerIdRot.Text),
                       PWideChar(edtPassRot.Text), PWideChar(edtTickerRot.Text),
                       PWideChar(cbBolsaRot.Items.Strings[cbBolsaRot.ItemIndex]),
                       StrToFloat(edtPriceRot.Text), StrToFloat(edtPriceStopRot.Text),
                       StrToInt(edtAmountRot.Text))
    else if sText = 'SendChangeOrder' then
      nRes:= SendChangeOrder(PWideChar(edtBrokerAccRot.Text), PWideChar(edtBrokerIdRot.Text),
                      PWideChar(edtPassRot.Text), PWideChar(edtClOrdIdRot.Text),
                      StrToFloat(edtPriceRot.Text), StrToInt(edtAmountRot.Text))
    else if sText = 'SendCancelOrder' then
      nRes:= SendCancelOrder(PWideChar(edtBrokerAccRot.Text), PWideChar(edtBrokerIdRot.Text),
                      PWideChar(edtClOrdIdRot.Text), PWideChar(edtPassRot.Text))
    else if sText = 'SendCancelOrders' then
      nRes:= SendCancelOrders(PWideChar(edtBrokerAccRot.Text), PWideChar(edtBrokerIdRot.Text),
                       PWideChar(edtPassRot.Text), PWideChar(edtTickerRot.Text),
                       PWideChar(cbBolsaRot.Items.Strings[cbBolsaRot.ItemIndex]))
    else if sText = 'SendCancelAllOrders' then
      nRes:= SendCancelAllOrders(PWideChar(edtBrokerAccRot.Text), PWideChar(edtBrokerIdRot.Text),
                          PWideChar(edtPassRot.Text))
    else if sText = 'SendZeroPosition' then
      nRes:= SendZeroPosition(PWideChar(edtBrokerAccRot.Text), PWideChar(edtBrokerIdRot.Text),
                       PWideChar(edtTickerRot.Text), PWideChar(cbBolsaRot.Items.Strings[cbBolsaRot.ItemIndex]),
                       PWideChar(edtPassRot.Text), StrToFloat(edtPriceRot.Text))
    else if sText = 'SendZeroPositionAtMarket' then
      nRes:= SendZeroPositionAtMarket(PWideChar(edtBrokerAccRot.Text), PWideChar(edtBrokerIdRot.Text),
                       PWideChar(edtTickerRot.Text), PWideChar(cbBolsaRot.Items.Strings[cbBolsaRot.ItemIndex]),
                       PWideChar(edtPassRot.Text))
    else if sText = 'SendMarketSellOrder' then
      nRes:= SendMarketSellOrder(PWideChar(edtBrokerAccRot.Text), PWideChar(edtBrokerIdRot.Text),
                   PWideChar(edtPassRot.Text), PWideChar(edtTickerRot.Text),
                   PWideChar(cbBolsaRot.Items.Strings[cbBolsaRot.ItemIndex]), StrToInt(edtAmountRot.Text))
    else if sText = 'SendMarketBuyOrder' then
      nRes:= SendMarketBuyOrder(PWideChar(edtBrokerAccRot.Text), PWideChar(edtBrokerIdRot.Text),
                   PWideChar(edtPassRot.Text), PWideChar(edtTickerRot.Text),
                   PWideChar(cbBolsaRot.Items.Strings[cbBolsaRot.ItemIndex]), StrToInt(edtAmountRot.Text))
    else if sText = 'GetAccount' then
      nRes:= GetAccount()
    else if sText = 'GetOrders' then
      nRes:= GetOrders(PWideChar(edtBrokerAccRot.Text), PWideChar(edtBrokerIdRot.Text),
                PWideChar(DateToStr(dateStartRot.Date)), PWideChar(DateToStr(dateEndRot.Date)))
    else if sText = 'GetOrder' then
      nRes:= GetOrder(PWideChar(edtClOrdIdRot.Text))
    else if sText = 'GetOrderProfitID' then
      nRes:= GetOrderProfitID(StrToInt(edtProfitIdRot.Text))
    else if sText = 'GetPosition' then
      pRes:= GetPosition(PWideChar(edtBrokerAccRot.Text), PWideChar(edtBrokerIdRot.Text),
                  PWideChar(edtTickerRot.Text), PWideChar(cbBolsaRot.Items.Strings[cbBolsaRot.ItemIndex]))
    else if sText = 'GetHistoryTrades' then
      nRes:= GetHistoryTrades(PWideChar(edtTickerMd.Text), PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]),
                       PWideChar(DateToStr(dateStartMd.Date) + ' ' + TimeToStr(timeStartMd.Time)),
                       PWideChar(DateToStr(dateEndMd.Date) + ' ' + TimeToStr(timeEndMd.Time)))
    else if sText = 'GetSerieHistory' then
      nRes:= GetSerieHistory(PWideChar(edtTickerMd.Text), PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]),
                       PWideChar(DateToStr(dateStartMd.Date) + ' ' + TimeToStr(timeStartMd.Time)),
                       PWideChar(DateToStr(dateEndMd.Date) + ' ' + TimeToStr(timeEndMd.Time)), 0, 0)
    else if sText = 'RequestTickerInfo' then
      nRes:= RequestTickerInfo(PWideChar(edtTickerMd.Text), PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]))
    else if sText = 'SubscribeAdjustHistory' then
      nRes:= SubscribeAdjustHistory(PWideChar(edtTickerMd.Text), PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]))
    else if sText = 'UnsubscribeAdjustHistory' then
      nRes:= UnsubscribeAdjustHistory(PWideChar(edtTickerMd.Text), PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]))
    else if sText = 'GetServerClock' then
      ServerClock(sText)
    else if sText = 'GetLastDailyClose' then
      LastDailyClose(sText);

    if nRes <> -1 then
      begin
        if (nRes >= Low(Integer)) and (nRes <= High(Integer))
          then mmFunc.Lines.Add(Format(sText + ': 0x%x', [Integer(nRes)]))
          else mmFunc.Lines.Add(Format(sText + ': 0x%x', [nRes]));
      end
    else if sRes <> EmptyStr then
      mmFunc.Lines.Add(Format(sText + ': %s', [sRes]))
    else if pRes <> nil then
    begin
      mmFunc.Lines.Add(Format(sText + ': %s', [DecryptArrayPosition(pRes)]));
    end;
  end;
end;

procedure TfrmClient.cbFunctionsChange(Sender: TObject);
var
  lItem: TType;
begin
  // muda a tab com os componentes necessarios //

  if cbFunctions.ItemIndex <> -1 then
  begin
    lItem:= TType(cbFunctions.Items.Objects[cbFunctions.ItemIndex]);
    btnExecute.Enabled:= (lItem <> tConfig);
    if (lItem = tRot) then
      pcType.ActivePage:= tabRot
    else if (lItem = tMD) then
      pcType.ActivePage:= tabMd
    else
      pcType.ActivePage:= tabConfig;
    EnableDisableControls(pcType.ActivePage, cbFunctions.Items.Strings[cbFunctions.ItemIndex]);
  end;
end;

procedure GenericLogUpdate(AValue: String);
begin
  frmClient.mmUpdates.Lines.Add(AValue);
end;

procedure TfrmClient.ServerClock(AText: String);
var
  lDate: TDateTime;
  lYear, lMonth, lDay, lHour, lMin, lSec, lMilisec: Integer;
  lData: TDateTime;
  nRes: ShortInt;
begin
  nRes:= GetServerClock(lDate, lYear, lMonth, lDay, lHour, lMin, lSec, lMilisec);

  mmFunc.Lines.Add(Format(AText + ': %d | %s', [nRes, DateTimeToStr(lData)]));
end;

procedure TfrmClient.LastDailyClose(AText: String);
var
  lClose: Double;
  nRes: ShortInt;
begin
  lClose:= 0;
  nRes:= GetLastDailyClose(PWideChar(edtTickerMd.Text), PWideChar(cbBolsaMd.Items.Strings[cbBolsaMd.ItemIndex]),
                           lClose, 1);
  mmFunc.Lines.Add(Format(AText + ': %d | %n', [nRes, lClose]))
end;

procedure TfrmClient.CopyMemoryToString(var ADest: String; Source: Pointer;
  Length: NativeUInt);
var
  iIndex  : Integer;
  pMyArray : PByteArray;
begin
  if Length > 0 then
    begin
      pMyArray := Source;
      SetLength(ADest, Length);
      For iIndex := 1 to Length do
        ADest[iIndex] := Chr(pMyArray[iIndex - 1]);
    end
  else
    ADest:= '';
end;

function TfrmClient.DecryptArrayPosition(AData: Pointer): String;
type
  TBrokerOrderSide = (bosUnknown = 0, bosBuy=1, bosSell=2);
var
  nQtd      : Integer;
  nTam      : Integer;
  nIndex    : Integer;
  nStart    : Integer;
  sAux      : String;
  sResult   : String;
  nLength   : Word;
  pBuffer   : PByteArray;
begin
  pBuffer := AData;
  nQtd    := pBuffer[0];
  nTam    := PInteger(@pBuffer[4])^;
  nStart  := 8;
  sResult := EmptyStr;
  for nIndex := 0 to nQtd - 1 do
  begin
    //////////////////////////////////////////////////////////////////
    // Copia a ID corretora
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;
    sResult:= sAux + '|';

    //////////////////////////////////////////////////////////////////
    // Copia a string de Conta
    nLength := PWord(@pBuffer[nStart])^;
    nStart  := nStart + 2;

    SetLength(sAux, nLength);
    if nLength > 0 then
      CopyMemoryToString(sAux, @pBuffer[nStart], nLength);
    nStart := nStart + nLength;
    sResult:= sResult + sAux + '|';

    //////////////////////////////////////////////////////////////////
    // Copia a string do Titular
    nLength := PWord(@pBuffer[nStart])^;;
    nStart  := nStart + 2;

    SetLength(sAux, nLength);
    if nLength > 0 then
      CopyMemoryToString(sAux, @pBuffer[nStart], nLength);
    nStart := nStart + nLength;
    sResult:= sResult + sAux + '|';

    //////////////////////////////////////////////////////////////////
    // Copia a string do Ticker
    nLength := PWord(@pBuffer[nStart])^;;
    nStart  := nStart + 2;

    SetLength(sAux, nLength);
    if nLength > 0 then
      CopyMemoryToString(sAux, @pBuffer[nStart], nLength);
    nStart := nStart + nLength;
    sResult:= sResult + sAux + '|';

    //////////////////////////////////////////////////////////////////
    // Copia TodayPosition nQtd
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;
    sResult:= sResult + sAux + '|';

    //////////////////////////////////////////////////////////////////
    // Copia TodayPosition sPrice
    sAux := FloatToStr(PDouble(@pBuffer[nStart])^);
    nStart := nStart + 8;
    sResult:= sResult + sAux + '|';

    //utilizado no Day
    //////////////////////////////////////////////////////////////////////
    // Salva SellAvgPriceToday
    sAux := FloatToStr(PDouble(@pBuffer[nStart])^);
    nStart := nStart + 8;

    //////////////////////////////////////////////////////////////////////
    // Salva SellQtdToday
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;

    //////////////////////////////////////////////////////////////////////
    // Salva BuyAvgPriceToday
    sAux := FloatToStr(PDouble(@pBuffer[nStart])^);
    nStart := nStart + 8;


    //////////////////////////////////////////////////////////////////////
    // Salva BuyQtdToday
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;

    //Custodia
    //////////////////////////////////////////////////////////////////////
    // Salva Quantidade em D+1
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;

    //////////////////////////////////////////////////////////////////////
    // Salva Quantidade em D+2
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;

    //////////////////////////////////////////////////////////////////////
    // Salva Quantidade em D+3
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;

    //////////////////////////////////////////////////////////////////////
    // Salva Quantidade bloqueada
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;

    //////////////////////////////////////////////////////////////////////
    // Salva Quantidade Pending
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;

    //////////////////////////////////////////////////////////////////////
    // Salva Quantidade alocada
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;
    sResult:= sResult + sAux + '|';

    //////////////////////////////////////////////////////////////////////
    // Salva Quantidade provisionada
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;
    sResult:= sResult + sAux + '|';

    //////////////////////////////////////////////////////////////////////
    // Salva Quantidade da posição
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;
    sResult:= sResult + sAux + '|';

    //////////////////////////////////////////////////////////////////////
    // Salva Quantidade Disponível
    sAux := IntToStr(PInteger(@pBuffer[nStart])^);
    nStart := nStart + 4;
    sResult:= sResult + sAux + '|';

    //////////////////////////////////////////////////////////////////////
    // Salva Lado da posição
    case TBrokerOrderSide(PByte(@pBuffer[nStart])^) of
      bosSell: sResult := sResult + 'Vendido|';
      bosBuy:  sResult := sResult + 'Comprado|';
    else
      sResult := sResult +'Unknown|';
    end;
   end;
   FreePointer(AData,nTam);
   Result:= sResult;
end;

procedure TfrmClient.EnableDisableControls(ATab: TTabSheet; AItem: String);
  procedure DisableAllControls;
  var
    I: Integer;
  begin
    for I := 0 to ATab.ControlCount-1 do
      ATab.Controls[i].Enabled:= false;
  end;
var
  idx: integer;
begin
  DisableAllControls;
  idx:= cbFunctions.ItemIndex;
  // defs //
  lbTitleRot.Enabled:= true;
  lbTitleMd.Enabled:= true;
  lbTitleCfg.Enabled:= true;

  // cond //
  if ATab = tabMd then
  begin
    lbTickerMd.Enabled := (idx in [0..5, 22..24, 31, 35..36, 42]);
    edtTickerMd.Enabled:= lbTickerMd.Enabled;
    lbBolsaMd.Enabled:= (idx in [0..5, 22..24, 31..32, 35..36, 42]);
    cbBolsaMd.Enabled:= lbBolsaMd.Enabled;
    lbAgentIdMd.Enabled:= (idx in [6..7]);
    edtAgentId.Enabled := lbAgentIdMd.Enabled;
    lbDateStartMd.Enabled:= (idx in [22..24]);
    dateStartMd.Enabled  := lbDateStartMd.Enabled;
    lbTimeStartMd.Enabled:= (idx in [22..24]);
    timeStartMd.Enabled  := lbTimeStartMd.Enabled;
    lbDateEndMd.Enabled:= (idx in [23..24]);
    dateEndMd.Enabled   := lbDateEndMd.Enabled;
    lbTimeEndMd.Enabled:= (idx in [23..24]);
    timeEndMd.Enabled  := lbTimeEndMd.Enabled;

    edtBookPos.Enabled:= (idx in [2..5]);
    mmBookPos.Enabled:= edtBookPos.Enabled;
    btnBookPos.Enabled:= edtBookPos.Enabled;
  end
  else if ATab = tabRot then
  begin
    lbContaRot.Enabled     := (idx in [8..16, 18, 21, 42..44]);
    edtBrokerAccRot.Enabled:= lbContaRot.Enabled;
    lbBrokerIdRot.Enabled := (idx in [8..16, 18, 21, 42..44]);
    edtBrokerIdRot.Enabled:= lbBrokerIdRot.Enabled;
    lbPassRot.Enabled := (idx in [8..16, 42..44]);
    edtPassRot.Enabled:= lbPassRot.Enabled;
    lbTickerRot.Enabled := (idx in [8..11, 14, 16, 21, 42..44]);
    edtTickerRot.Enabled:= lbTickerRot.Enabled;
    lbBolsaRot.Enabled:= (idx in [8..11, 14, 16, 21, 42..44]);
    cbBolsaRot.Enabled:= lbBolsaRot.Enabled;
    lbPriceRot.Enabled := (idx in [8..12, 16]);
    edtPriceRot.Enabled:= lbPriceRot.Enabled;
    lbAmountRot.Enabled := (idx in [8..12, 42..43]);
    edtAmountRot.Enabled:= lbAmountRot.Enabled;
    lbPriceStopRot.Enabled := (idx in [10..11]);
    edtPriceStopRot.Enabled:= lbPriceStopRot.Enabled;
    lbClOrdIdRot.Enabled := (idx in [12..13, 19]);
    edtClOrdIdRot.Enabled:= lbClOrdIdRot.Enabled;
    lbProfitIdRot.Enabled := (idx in [20]);
    edtProfitIdRot.Enabled:= lbProfitIdRot.Enabled;
    lbDateStartRot.Enabled:= (idx in [18]);
    dateStartRot.Enabled  := lbDateStartRot.Enabled;
    lbDateEndRot.Enabled:= (idx in [18]);
    dateEndRot.Enabled  := lbDateEndRot.Enabled;
  end;
end;

destructor TfrmClient.Destroy;
begin
  if Self.Connected then
    DLLFinalize;
  freeAndNil(Self.Connection);
  freeAndNil(Self.ListBuyPriceBook);
  freeAndNil(Self.ListSellPriceBook);
  freeAndNil(Self.ListBuyOfferBook);
  freeAndNil(Self.ListSellOfferBook);
  inherited;
end;

procedure TfrmClient.ConnectionNotify(Sender: TObject; const Item: Integer; Action: TCollectionNotification);
var
  info, md, rot: integer;
begin
  if not (Sender is TDictionary<TConnStateType, Integer>) then
    Exit;

  (Sender as TDictionary<TConnStateType, Integer>).TryGetValue(cstMarketData, md);
  (Sender as TDictionary<TConnStateType, Integer>).TryGetValue(cstInfo, info);
  (Sender as TDictionary<TConnStateType, Integer>).TryGetValue(cstRoteamento, rot);

  imgRotOff.Visible:= (rot = 0);
  imgInfoOff.Visible:= (info = 0);
  imgMdOff.Visible:= (md = 0);

  imgRotOn.Visible:= (rot = 1);
  imgInfoOn.Visible:= (info = 1);
  imgMdOn.Visible:= (md = 1);

  btnInitialize.Enabled:= not ((md=1) and (info=1));
  btnFinalize.Enabled  := not ((md=0) and (info=0));
end;

procedure TfrmClient.btnClearUpdatesClick(Sender: TObject);
begin
  mmUpdates.Lines.BeginUpdate;
  try
    mmUpdates.Lines.Clear;
  finally
    mmUpdates.Lines.EndUpdate;
  end;
end;

procedure TfrmClient.LoadImages;
begin
  imgList.GetBitmap(0, imgMdOff.Picture.Bitmap);
  imgMdOff.Refresh;
  imgList.GetBitmap(0, imgInfoOff.Picture.Bitmap);
  imgInfoOff.Refresh;
  imgList.GetBitmap(0, imgRotOff.Picture.Bitmap);
  imgRotOff.Refresh;

  imgList.GetBitmap(1, imgMdOn.Picture.Bitmap);
  imgMdOn.Refresh;
  imgList.GetBitmap(1, imgInfoOn.Picture.Bitmap);
  imgInfoOn.Refresh;
  imgList.GetBitmap(1, imgRotOn.Picture.Bitmap);
  imgRotOn.Refresh;
end;

procedure TfrmClient.DecryptPriceArray(ASource: Pointer; ATarget: TList);
var
  nQtd      : Integer;
  nTam      : Integer;
  nIndex    : Integer;
  nStart    : Integer;
  pBuffer   : PByteArray;
  Group     : PGroupPrice;
begin
  for nIndex := 0 to ATarget.Count - 1 do
    begin
      Group := ATarget[nIndex];
      Dispose(Group);
    end;
  ATarget.Clear;

  pBuffer := ASource;
  nQtd := PInteger(@pBuffer[0])^;
  nTam := PInteger(@pBuffer[4])^;
  nStart := 8;
  for nIndex := 0 to nQtd - 1 do
    begin
      New(Group);
      // Copia sPrice
      Group.sPrice := PDouble(@pBuffer[nStart])^;
      nStart       := nStart + 8;

      // Copia nQtd
      Group.nQtd := PInteger(@pBuffer[nStart])^;
      nStart     := nStart + 4;

      // Copia nCount
      Group.nCount := PInteger(@pBuffer[nStart])^;
      nStart       := nStart + 4;

      ATarget.Add(Group)
    end;
  FreePointer(ASource, nStart);
end;

procedure TfrmClient.DecryptPriceArrayV2(ASource: Pointer; ATarget: TList);
var
  nQtd      : Integer;
  nTam      : Integer;
  nIndex    : Integer;
  nStart    : Integer;
  pBuffer   : PByteArray;
  Group     : PGroupPrice;
begin
  for nIndex := 0 to ATarget.Count - 1 do
    begin
      Group := ATarget[nIndex];
      Dispose(Group);
    end;
  ATarget.Clear;

  pBuffer := ASource;
  nQtd := PInteger(@pBuffer[0])^;
  nTam := PInteger(@pBuffer[4])^;
  nStart := 8;
  for nIndex := 0 to nQtd - 1 do
    begin
      New(Group);
      // Copia sPrice
      Group.sPrice := PDouble(@pBuffer[nStart])^;
      nStart       := nStart + 8;

      // Copia nQtd
      Group.nQtd := PInt64(@pBuffer[nStart])^;
      nStart     := nStart + 8;

      // Copia nCount
      Group.nCount := PInteger(@pBuffer[nStart])^;
      nStart       := nStart + 4;

      ATarget.Add(Group)
    end;
  FreePointer(ASource, nStart);
end;

procedure UpdatePriceBook(                nVersion : Integer;
                                          rAssetID : TAssetIDRec ;
          nAction , nPosition, Side, nQtds, nCount : Integer;
                                            sPrice : Double;
                             pArraySell, pArrayBuy : Pointer);
var
  lBook: TList;
  Group: PGroupPrice;
  iIndex: Integer;
begin
  with frmClient do
  begin
    // atFullBook implicito //
      if Assigned(pArraySell) then
        begin
          case nVersion of
            1 : DecryptPriceArray(pArraySell, ListSellPriceBook);
            2 : DecryptPriceArrayV2(pArraySell, ListSellPriceBook);
          end;
        end;
      if Assigned(pArrayBuy) then
        begin
          case nVersion of
            1 : DecryptPriceArray(pArrayBuy, ListBuyPriceBook);
            2 : DecryptPriceArrayV2(pArrayBuy, ListBuyPriceBook);
          end;
        end;

    if Side = 0 then
      lBook:= ListBuyPriceBook
    else
      lBook:= ListSellPriceBook;


    case TActionType(nAction) of
        atAdd:        begin
                        if (lBook <> nil) and (nPosition >= 0) and (nPosition <= lBook.Count) then
                        begin
                          // Cria a oferta //
                          New(Group);
                          Group.sPrice:= sPrice;
                          Group.nQtd  := nQtds;
                          Group.nCount:= nCount;

                          lBook.Insert(lBook.Count - nPosition, Group);
                        end;
                      end;

      atEdit:         begin
                        if (lBook <> nil) and (nPosition >= 0) and (nPosition < lBook.Count) then
                        begin
                          Group := lBook.Items[lBook.Count - 1 - nPosition];
                          // Atualiza a oferta //
                          Group.nQtd   := Group.nQtd + nQtds;
                          Group.nCount := Group.nCount + nCount;
                        end;
                      end;

      atDelete:       begin
                        if (lBook <> nil) and (nPosition >= 0) and (nPosition < lBook.Count) then
                         begin
                           // Apaga a oferta //
                           Group := lBook.Items[lBook.Count - 1 - nPosition];
                           Dispose(Group);
                           lBook.Delete(lBook.Count - 1 - nPosition);
                         end;
                      end;

      atDeleteFrom:   begin
                        if (lBook <> nil) and (nPosition >= 0) and (nPosition < lBook.Count) then
                        begin
                          // Apaga as ofertas //
                          For iIndex := lBook.Count-1-nPosition to lBook.Count-1 do
                            begin
                              Group := lBook.Items[iIndex];
                              Dispose(Group);
                            end;
                          lBook.Count := lBook.Count-1-nPosition;
                        end
                      end;
    end;

    if (nPosition = StrToInt(edtBookPos.Text)) and (nPosition > 0) and (nPosition <= lBook.Count) then
    begin
      Group:= lBook.Items[lBook.Count-1 -nPosition];
      mmBookPos.Text := rAssetID.pchTicker + #13#10 + ' Ação=' + GetEnumName(TypeInfo(TActionType), nAction) +
                                             #13#10 + ' PosiçãoUp=' + IntToStr(nPosition) +
                                             #13#10 + ' Side=' + IntToStr(Side) +
                                             #13#10 + ' Qtd=' + IntToStr(Group.nQtd) +
                                             #13#10 + ' Count=' + IntToStr(Group.nCount) +
                                             #13#10 + ' Price=' + FloatToStr(Group.sPrice);
    end;


  end;
end;

procedure TfrmClient.btnBookPosClick(Sender: TObject);
var
  PriceOffer: PGroupPrice;
  Offer     : PGroupOffer;
begin
  // 2,3 = pricebook
  // 4,5 = offerbook
  if (StrToInt(edtBookPos.Text) <= ListBuyPriceBook.Count) and (StrToInt(edtBookPos.Text) >= 0) then
  begin
    if cbFunctions.ItemIndex in [2,3] then
    begin
      PriceOffer  := ListBuyPriceBook.Items[ListBuyPriceBook.Count - 1 - StrToInt(edtBookPos.Text)];

      mmBookPos.Text :=     ' Side=Buy' +
                            #13#10 + ' Qtd='     + IntToStr(PriceOffer.nQtd) +
                            #13#10 + ' Count='   + IntToStr(PriceOffer.nCount) +
                            #13#10 + ' Price='   + FloatToStr(PriceOffer.sPrice);
    end
    else if cbFunctions.ItemIndex in [4,5] then
    begin
      Offer:= ListBuyOfferBook.Items[ListBuyOfferBook.Count - 1 - StrToInt(edtBookPos.Text)];

      mmBookPos.Text :=     ' Posição='          + IntToStr(Offer.nPosition) +
                            #13#10 + ' Side=Buy' +
                            #13#10 + ' Qtd='     + IntToStr(Offer.nQtd) +
                            #13#10 + ' Agent='   + IntToStr(Offer.nAgent) +
                            #13#10 + ' Offer='   + IntToStr(Offer.nOfferID) +
                            #13#10 + ' Price='   + FloatToStr(Offer.sPrice) +
                            #13#10 + ' Date='    + Offer.strDtOffer;
    end;
  end;
end;

procedure TfrmClient.DecryptOfferArray(ASouce: Pointer; ATarget: TList);
var
  nQtd      : Integer;
  nTam      : Integer;
  nIndex    : Integer;
  nStart    : Integer;
  strAux    : String;
  nLength   : Word;
  pBuffer   : PByteArray;
  Offer     : PGroupOffer;
begin
  for nIndex := 0 to ATarget.Count - 1 do
    begin
      Offer := ATarget[nIndex];
      Dispose(Offer);
    end;
  ATarget.Clear;

  pBuffer := ASouce;
  nQtd := PInteger(@pBuffer[0])^;
  nTam := PInteger(@pBuffer[4])^;
  nStart := 8;
  for nIndex := 0 to nQtd - 1 do
    begin
      New(Offer);
      //////////////////////////////////////////////////////////////////
      // Copia sPrice
      Offer.sPrice := PDouble(@pBuffer[nStart])^;
      nStart       := nStart + 8;

      //////////////////////////////////////////////////////////////////
      // Copia nQtd
      Offer.nQtd := PInteger(@pBuffer[nStart])^;
      nStart     := nStart + 4;

      //////////////////////////////////////////////////////////////////
      // Copia nAgent
      Offer.nAgent := PInteger(@pBuffer[nStart])^;
      nStart       := nStart + 4;

      //////////////////////////////////////////////////////////////////
      // Copia nOfferID
      Offer.nOfferID := PInt64(@pBuffer[nStart])^;
      nStart         := nStart + 8;

      //////////////////////////////////////////////////////////////////
      // Copia dtOffer
      nLength := PWord(@pBuffer[nStart])^;
      nStart  := nStart + 2;

      SetLength(strAux, nLength);
      if nLength > 0 then
        CopyMemoryToString(strAux, @pBuffer[nStart], nLength);
      nStart := nStart + nLength;

      Offer.strDtOffer := strAux;

      ATarget.Add(Offer);
    end;
  FreePointer(ASouce, nStart);
end;

procedure TfrmClient.DecryptOfferArrayV2(ASouce: Pointer; ATarget: TList);
var
  nQtd      : Integer;
  nTam      : Integer;
  nIndex    : Integer;
  nStart    : Integer;
  strAux    : String;
  nLength   : Word;
  pBuffer   : PByteArray;
  Offer     : PGroupOffer;
begin
  for nIndex := 0 to ATarget.Count - 1 do
    begin
      Offer := ATarget[nIndex];
      Dispose(Offer);
    end;
  ATarget.Clear;

  pBuffer := ASouce;
  nQtd := PInteger(@pBuffer[0])^;
  nTam := PInteger(@pBuffer[4])^;
  nStart := 8;
  for nIndex := 0 to nQtd - 1 do
    begin
      New(Offer);
      //////////////////////////////////////////////////////////////////
      // Copia sPrice
      Offer.sPrice := PDouble(@pBuffer[nStart])^;
      nStart       := nStart + 8;

      //////////////////////////////////////////////////////////////////
      // Copia nQtd
      Offer.nQtd := PInt64(@pBuffer[nStart])^;
      nStart     := nStart + 8;

      //////////////////////////////////////////////////////////////////
      // Copia nAgent
      Offer.nAgent := PInteger(@pBuffer[nStart])^;
      nStart       := nStart + 4;

      //////////////////////////////////////////////////////////////////
      // Copia nOfferID
      Offer.nOfferID := PInt64(@pBuffer[nStart])^;
      nStart         := nStart + 8;

      //////////////////////////////////////////////////////////////////
      // Copia dtOffer
      nLength := PWord(@pBuffer[nStart])^;
      nStart  := nStart + 2;

      SetLength(strAux, nLength);
      if nLength > 0 then
        CopyMemoryToString(strAux, @pBuffer[nStart], nLength);
      nStart := nStart + nLength;

      Offer.strDtOffer := strAux;

      ATarget.Add(Offer);
    end;
  FreePointer(ASouce, nStart);
end;

procedure UpdateOfferBook(                          nVersion : Integer;
                                                    rAssetID : TAssetIDRec ;
                      nAction, nPosition, Side, nQtd, nAgent : Integer;
                                                    nOfferID : Int64;
                                                      sPrice : Double;
        bHasPrice, bHasQtd, bHasDate, bHasOfferID, bHasAgent : Char;
                                                    pwcDate  : PWideChar;
                                       pArraySell, pArrayBuy : Pointer);
var
  lBook    : TList;
  Group    : PGroupOffer;
  iIndex   : Integer;
begin
  with frmClient do
    begin
      if Assigned(pArraySell) then
        begin
          case nVersion of
            1 : DecryptOfferArray(pArraySell, ListSellOfferBook);
            2 : DecryptOfferArrayV2(pArraySell, ListSellOfferBook);
          end;
        end;
      if Assigned(pArrayBuy) then
        begin
          case nVersion of
            1 : DecryptOfferArray(pArrayBuy, ListSellOfferBook);
            2 : DecryptOfferArrayV2(pArrayBuy, ListSellOfferBook);
          end;
        end;

      if Side = 0
        then lBook := ListBuyOfferBook
        else lBook := ListSellOfferBook;

      Case TActionType(nAction) of
        atAdd:         begin
                          if (lBook <> nil) and (nPosition >= 0) and (nPosition <= lBook.Count) then
                            begin
                              New(Group);
                              Group.nOfferID   := nOfferID;
                              Group.nAgent     := nAgent;
                              Group.nQtd       := nQtd;
                              Group.nPosition  := nPosition;
                              Group.sPrice     := sPrice;
                              Group.strDtOffer := pwcDate;
                              //////////////////////////////////////////////////////////////////////////
                              // Cria a oferta
                              lBook.Insert(lBook.Count - nPosition, Group);
                            end
                       end;

        atDelete:      begin
                         //////////////////////////////////////////////////////////////////////////////
                        // Pega a oferta
                        if (lBook <> nil) and (nPosition >= 0) and (nPosition < lBook.Count) then
                          begin
                            //////////////////////////////////////////////////////////////////////////
                            // Apaga a oferta
                            Group := lBook.Items[lBook.Count - 1 - nPosition];
                            Dispose(Group);
                            lBook.Delete(lBook.Count - 1 - nPosition);
                          end
                       end;

        atDeleteFrom:  begin
                          //////////////////////////////////////////////////////////////////////////////
                          // Pega a oferta
                          if (lBook <> nil) and (nPosition >= 0) and (nPosition < lBook.Count) then
                            begin
                              //////////////////////////////////////////////////////////////////////////
                              // Apaga as ofertas
                              For iIndex := lBook.Count-1-nPosition to lBook.Count-1 do
                                begin
                                  Group := lBook.Items[iIndex];

                                  Dispose(Group);
                                end;
                              lBook.Count := lBook.Count-1-nPosition;
                            end
                       end;

        atEdit:        begin
                        //////////////////////////////////////////////////////////////////////////////
                        // Pega a oferta
                        if (lBook <> nil) and (nPosition >= 0) and (nPosition < lBook.Count) then
                          begin
                            Group    := lBook.Items[lBook.Count - 1 - nPosition];
                            //////////////////////////////////////////////////////////////////////////
                            // Atualiza a oferta
                            if Boolean(bHasQtd) then
                              Group.nQtd := Group.nQtd + nQtd;
                            if Boolean(bHasPrice) then
                              Group.sPrice := Group.sPrice;
                            if Boolean(bHasDate) then
                              Group.strDtOffer := pwcDate;
                            if Boolean(bHasAgent) then
                              Group.nAgent := nAgent;
                            if Boolean(bHasOfferID) then
                              Group.nOfferID := nOfferID;
                          end;
                       end;
      end;

      if (nPosition = StrToInt(edtBookPos.Text)) and ((lBook.Count - 1 - nPosition) > 0) then
        begin
          Group  := lBook.Items[lBook.Count - 1 - nPosition];
          mmBookPos.Text := rAssetID.pchTicker + #13#10 + ' Ação=' + IntToStr(nAction) +
                                                 #13#10 + ' PosiçãoUp=' + IntToStr(nPosition) +
                                                 #13#10 + ' Posição=' + IntToStr(Group.nPosition) +
                                                 #13#10 + ' Side=' + IntToStr(Side) +
                                                 #13#10 + ' Qtd=' + IntToStr(Group.nQtd) +
                                                 #13#10 + ' Agent=' + IntToStr(Group.nAgent) +
                                                 #13#10 + ' Offer=' + IntToStr(Group.nOfferID) +
                                                 #13#10 + ' Price=' + FloatToStr(Group.sPrice) +
                                                 #13#10 + ' Date=' + Group.strDtOffer;
        end;
    end;
end;

end.
