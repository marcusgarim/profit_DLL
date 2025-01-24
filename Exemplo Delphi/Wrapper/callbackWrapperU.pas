unit callbackWrapperU;

interface

uses
  callbackTypeU, SysUtils, TypInfo, Classes, System.Generics.Collections, structs;

  procedure StateCallback                                      (nConnStateType , nResult : Integer) stdcall; forward;

  procedure HistoryCallback                                                   (rAssetID  : TAssetIDRec;
                                        nCorretora , nQtd, nTradedQtd, nLeavesQtd, nSide : Integer;
                                                           sPrice, sStopPrice, sAvgPrice : Double;
                                                                               nProfitID : Int64;
                                        TipoOrdem, Conta, Titular, ClOrdID, Status, Date : PWideChar) stdcall; forward;

  procedure OrderChangeCallback                                               (rAssetID  : TAssetIDRec;
                                        nCorretora , nQtd, nTradedQtd, nLeavesQtd, nSide : Integer;
                                                           sPrice, sStopPrice, sAvgPrice : Double;
                                                                               nProfitID : Int64;
                           TipoOrdem, Conta, Titular, ClOrdID, Status, Date, TextMessage : PWideChar) stdcall; forward;


  procedure AccountCallback                                                  (nCorretora : Integer;
                                           CorretoraNomeCompleto, AccountID, NomeTitular : PWideChar) stdcall; forward;

  procedure NewTradeCallback                                                   (rAssetID : TAssetIDRec;
                                                                                 pwcDate : PWideChar;
                                                                            nTradeNumber : Cardinal;
                                                                            sPrice, sVol : Double;
                                                 nQtd, nBuyAgent, nSellAgent, nTradeType : Integer;
                                                                                 bIsEdit : Char) stdcall; forward;

  procedure NewDailyCallback                                                   (rAssetID : TAssetIDRec;
                                                                                 pwcDate : PWideChar;
  sOpen, sHigh, sLow, sClose, sVol, sAjuste, sMaxLimit, sMinLimit, sVolBuyer, sVolSeller : Double;
           nQtd, nNegocios, nContratosOpen, nQtdBuyer, nQtdSeller, nNegBuyer, nNegSeller : Integer) stdcall; forward;

  procedure PriceBookCallback                                                  (rAssetID : TAssetIDRec ;
                                                nAction , nPosition, Side, nQtds, nCount : Integer;
                                                                                  sPrice : Double;
                                                                   pArraySell, pArrayBuy : Pointer)  stdcall; forward;

  procedure OfferBookCallback                                                  (rAssetID : TAssetIDRec ;
                                                  nAction, nPosition, Side, nQtd, nAgent : Integer;
                                                                                nOfferID : Int64;
                                                                                  sPrice : Double;
                                    bHasPrice, bHasQtd, bHasDate, bHasOfferID, bHasAgent : Char;
                                                                                pwcDate  : PWideChar;
                                                                   pArraySell, pArrayBuy : Pointer) stdcall; forward;

  procedure PriceBookCallbackV2(
    rAssetID   : TAssetIDRec ;
    nAction    : Integer;
    nPosition  : Integer;
    Side       : Integer;
    nQtds      : Int64;
    nCount     : Int64;
    sPrice     : Double;
    pArraySell : Pointer;
    pArrayBuy  : Pointer)  stdcall; forward;

  procedure OfferBookCallbackV2                                                (rAssetID : TAssetIDRec ;
                                                                nAction, nPosition, Side : Integer;
                                                                                    nQtd : Int64;
                                                                                  nAgent : Integer;
                                                                                nOfferID : Int64;
                                                                                  sPrice : Double;
                                    bHasPrice, bHasQtd, bHasDate, bHasOfferID, bHasAgent : Char;
                                                                                pwcDate  : PWideChar;
                                                                   pArraySell, pArrayBuy : Pointer) stdcall; forward;

  procedure HistoryTradeCallback                                               (rAssetID : TAssetIDRec;
                                                                                 pwcDate : PWideChar;
                                                                            nTradeNumber : Cardinal;
                                                                            sPrice, sVol : Double;
                                                 nQtd, nBuyAgent, nSellAgent, nTradeType : Integer) stdcall; forward;

  procedure ProgressCallback                                                   (rAssetID : TAssetIDRec;
                                                                               nProgress : Integer) stdcall; forward;

  procedure TinyBookCallback                                                  (rAssetID  : TAssetIDRec;
                                                                               sPrice    : Double;
                                                                             nQtd, nSide : Integer) stdcall; forward;

  procedure AssetListCallback                                                   (AssetID : TAssetIDRec;
                                                                                 pwcName : PWideChar) stdcall; forward;

  procedure AssetListInfoCallback                                              (rAssetID : TAssetIDRec;
                                                                 pwcName, pwcDescription : PwideChar;
                    nMinOrderQtd, nMaxOrderQtd, nLote, stSecurityType, ssSecuritySubType : Integer;
                                                 sMinPriceIncrement, sContractMultiplier : Double;
                                                                   strValidDate, strISIN : PwideChar) stdcall; forward;

  procedure AssetListInfoCallbackV2                                            (rAssetID : TAssetIDRec;
                                                                 pwcName, pwcDescription : PwideChar;
                    nMinOrderQtd, nMaxOrderQtd, nLote, stSecurityType, ssSecuritySubType : Integer;
                                                 sMinPriceIncrement, sContractMultiplier : Double;
                               strValidDate, strISIN, strSetor, strSubSetor, strSegmento : PwideChar) stdcall; forward;

  procedure ChangeStateTickerCallback                                          (rAssetID : TAssetIDRec;
                                                                                 pwcDate : PWideChar;
                                                                                  nState : Integer) stdcall; forward;

  procedure AdjustHistoryCallback                                              (rAssetID : TAssetIDRec;
                                                                                  sValue : Double;
                              strAdjustType, strObserv, dtAjuste, dtDeliber, dtPagamento : PwideChar;
                                                                            nAffectPrice : Integer) stdcall; forward;

  procedure AdjustHistoryCallbackV2                                            (rAssetID : TAssetIDRec;
                                                                                  dValue : Double;
                              strAdjustType, strObserv, dtAjuste, dtDeliber, dtPagamento : PwideChar;
                                                                                  nFlags : Cardinal;
                                                                                   dMult : Double) stdcall; forward;

  procedure TheoreticalPriceCallback                                           (rAssetID : TAssetIDRec;
                                                                       sTheoreticalPrice : Double;
                                                                         nTheoreticalQtd : Int64) stdcall; forward;

  procedure ChangeCotationCallback                                             (rAssetID : TAssetIDRec;
                                                                                 pwcDate : PWideChar;
                                                                            nTradeNumber : Cardinal;
                                                                                  sPrice : Double) stdcall; forward;

  procedure HistoryCallbackV2                                                  (rAssetID : TAssetIDRec;
                              nCorretora, nQtd, nTradedQtd, nLeavesQtd, nSide, nValidity : Integer;
                                                           sPrice, sStopPrice, sAvgPrice : Double;
                                                                               nProfitID : Int64;
                                              TipoOrdem, Conta, Titular, ClOrdID, Status,
                                               Date, LastUpdate, CloseDate, ValidityDate : PWideChar) stdcall; forward;

  procedure OrderChangeCallbackV2                                              (rAssetID : TAssetIDRec;
                             nCorretora , nQtd, nTradedQtd, nLeavesQtd, nSide, nValidity : Integer;
                                                           sPrice, sStopPrice, sAvgPrice : Double;
                                                                               nProfitID : Int64;
                                        TipoOrdem, Conta, Titular, ClOrdID, Status, Date,
                                        LastUpdate, CloseDate, ValidityDate, TextMessage : PWideChar) stdcall; forward;

implementation

uses
  frmClientU, enums;

procedure StateCallback(nConnStateType , nResult : Integer) stdcall;
begin
  UpdateConnStatus(nConnStateType, nResult);
end;

procedure HistoryCallback                                           (rAssetID  : TAssetIDRec;
                              nCorretora , nQtd, nTradedQtd, nLeavesQtd, nSide : Integer;
                                                 sPrice, sStopPrice, sAvgPrice : Double;
                                                                     nProfitID : Int64;
                              TipoOrdem, Conta, Titular, ClOrdID, Status, Date : PWideChar) stdcall;
begin
  GenericLogUpdate(Format('THistoryCallback: %s | %d | %d | %n | %s | %s | %s', [rAssetId.pchTicker, nTradedQtd, nSide, sPrice, Conta, ClOrdId, Status] ));
end;

procedure OrderChangeCallback                                       (rAssetID  : TAssetIDRec;
                              nCorretora , nQtd, nTradedQtd, nLeavesQtd, nSide : Integer;
                                                 sPrice, sStopPrice, sAvgPrice : Double;
                                                                     nProfitID : Int64;
                 TipoOrdem, Conta, Titular, ClOrdID, Status, Date, TextMessage : PWideChar) stdcall;
begin
  GenericLogUpdate(Format('TOrderChangeCallback: %s | %s | %s | %s | %s | %s', [rAssetID.pchTicker, ClOrdId, Conta, Status, TextMessage, TipoOrdem]));
end;

procedure AccountCallback                                          (nCorretora : Integer;
                                 CorretoraNomeCompleto, AccountID, NomeTitular : PWideChar) stdcall;
begin
  GenericLogUpdate(Format('TAccountCallback: %d | %s | %s | %s', [nCorretora, CorretoraNomeCompleto, AccountId, NomeTitular]));
end;

procedure NewTradeCallback                                           (rAssetID : TAssetIDRec;
                                                                       pwcDate : PWideChar;
                                                                  nTradeNumber : Cardinal;
                                                                  sPrice, sVol : Double;
                                       nQtd, nBuyAgent, nSellAgent, nTradeType : Integer;
                                                                       bIsEdit : Char) stdcall;
begin
  GenericLogUpdate(Format('TNewTradeCallback: %s | %n | %d | %s', [rAssetID.pchTicker, sPrice, nQtd, GetEnumName(TypeInfo(TTradeType), nTradeType)]));
end;

procedure NewDailyCallback                                                   (rAssetID : TAssetIDRec;
                                                                               pwcDate : PWideChar;
sOpen, sHigh, sLow, sClose, sVol, sAjuste, sMaxLimit, sMinLimit, sVolBuyer, sVolSeller : Double;
         nQtd, nNegocios, nContratosOpen, nQtdBuyer, nQtdSeller, nNegBuyer, nNegSeller : Integer) stdcall;
begin
  GenericLogUpdate(Format('TNewDailyCallback '   +
                          #13#10 + 'Ticker: %s' +
                          #13#10 + 'Date:  %s'  +
                          #13#10 + 'Qtd:   %d'  +
                          #13#10 + 'Open:  %n'  +
                          #13#10 + 'High:  %n'  +
                          #13#10 + 'Low:   %n'  +
                          #13#10 + 'Close: %n'  +
                          #13#10 + 'Volume %n',
                          [rAssetId.pchTicker, pwcDate, nQtd, sOpen, sHigh, sLow, sClose, sVol]));
end;

procedure PriceBookCallback                       (rAssetID : TAssetIDRec ;
                   nAction , nPosition, Side, nQtds, nCount : Integer;
                                                     sPrice : Double;
                                      pArraySell, pArrayBuy : Pointer)  stdcall;
begin
  GenericLogUpdate(Format('TPriceBookCallback: %s | %d', [rAssetID.pchTicker, Side]));
  UpdatePriceBook(1, rAssetID, nAction, nPosition, Side, nQtds, nCount, sPrice, pArraySell, pArrayBuy);
end;

procedure PriceBookCallbackV2(
    rAssetID   : TAssetIDRec ;
    nAction    : Integer;
    nPosition  : Integer;
    Side       : Integer;
    nQtds      : Int64;
    nCount     : Int64;
    sPrice     : Double;
    pArraySell : Pointer;
    pArrayBuy  : Pointer); stdcall;
begin
  GenericLogUpdate(Format('TPriceBookCallbackV2: %s | %d', [rAssetID.pchTicker, Side]));
  UpdatePriceBook(2, rAssetID, nAction, nPosition, Side, nQtds, nCount, sPrice, pArraySell, pArrayBuy);
end;

procedure OfferBookCallback                       (rAssetID : TAssetIDRec ;
                     nAction, nPosition, Side, nQtd, nAgent : Integer;
                                                   nOfferID : Int64;
                                                     sPrice : Double;
       bHasPrice, bHasQtd, bHasDate, bHasOfferID, bHasAgent : Char;
                                                   pwcDate  : PWideChar;
                                      pArraySell, pArrayBuy : Pointer) stdcall;
begin
  GenericLogUpdate(Format('TOfferBookCallback: %s | %d', [rAssetID.pchTicker, Side]));
  UpdateOfferBook(1, rAssetID, nAction, nPosition, Side, nQtd, nAgent, nOfferID, sPrice, bHasPrice, bHasQtd, bHasDate, bHasOfferID, bHasAgent, pwcDate, pArraySell, pArrayBuy);
end;

procedure OfferBookCallbackV2                     (rAssetID : TAssetIDRec ;
                                   nAction, nPosition, Side : Integer;
                                                       nQtd : Int64;
                                                     nAgent : Integer;
                                                   nOfferID : Int64;
                                                     sPrice : Double;
       bHasPrice, bHasQtd, bHasDate, bHasOfferID, bHasAgent : Char;
                                                   pwcDate  : PWideChar;
                                      pArraySell, pArrayBuy : Pointer) stdcall;
begin
  GenericLogUpdate(Format('TOfferBookCallbackV2: %s | %d', [rAssetID.pchTicker, Side]));
  UpdateOfferBook(2, rAssetID, nAction, nPosition, Side, nQtd, nAgent, nOfferID, sPrice, bHasPrice, bHasQtd, bHasDate, bHasOfferID, bHasAgent, pwcDate, pArraySell, pArrayBuy);
end;

procedure HistoryTradeCallback  (rAssetID : TAssetIDRec;
                                  pwcDate : PWideChar;
                             nTradeNumber : Cardinal;
                             sPrice, sVol : Double;
  nQtd, nBuyAgent, nSellAgent, nTradeType : Integer) stdcall;
begin
  GenericLogUpdate(Format('THistoryTradeCallback: %s | %s | %n | %d | %s', [rAssetID.pchTicker, pwcDate, sPrice, nQtd, GetEnumName(TypeInfo(TTradeType), nTradeType)]));
end;

procedure ProgressCallback( rAssetID  : TAssetIDRec; nProgress : Integer) stdcall;
begin
  GenericLogUpdate(Format('TProgressCallback: %s | %d',[rAssetId.pchTicker, nProgress]));
end;

procedure TinyBookCallback  (rAssetID  : TAssetIDRec;
                             sPrice    : Double;
                           nQtd, nSide : Integer) stdcall;
begin
  GenericLogUpdate(Format('TinyBookCallback: %s | %n | %d | %d', [rAssetID.pchTicker, sPrice, nQtd, nSide]));
end;

procedure AssetListCallback(AssetID : TAssetIDRec; pwcName : PWideChar) stdcall;
begin
  GenericLogUpdate(Format('AssetListCallback: %s | %s',[AssetId.pchTicker, pwcName]));
end;

procedure AssetListInfoCallback                                             (rAssetID : TAssetIDRec;
                                                               pwcName, pwcDescription : PwideChar;
                  nMinOrderQtd, nMaxOrderQtd, nLote, stSecurityType, ssSecuritySubType : Integer;
                                               sMinPriceIncrement, sContractMultiplier : Double;
                                                                 strValidDate, strISIN : PwideChar) stdcall;
begin
  GenericLogUpdate(Format('TAssetListInfoCallback: %s | %s | %s | %s | %s | %s |',[rAssetId.pchTicker, pwcName, strValidDate, strISIN,
                   GetEnumName(TypeInfo(TSecurityType), stSecurityType), GetEnumName(TypeInfo(TSecuritySubType), ssSecuritySubType)]));
end;

procedure AssetListInfoCallbackV2                                           (rAssetID : TAssetIDRec;
                                                               pwcName, pwcDescription : PwideChar;
                  nMinOrderQtd, nMaxOrderQtd, nLote, stSecurityType, ssSecuritySubType : Integer;
                                               sMinPriceIncrement, sContractMultiplier : Double;
                             strValidDate, strISIN, strSetor, strSubSetor, strSegmento : PwideChar) stdcall;
begin
  GenericLogUpdate(Format('TAssetListInfoCallbackV2: %s | %s | %s | %s | %s | %s | %s',[rAssetId.pchTicker, pwcName, strValidDate, strISIN, strSetor, strSubSetor, StrSegmento]));
end;

procedure ChangeStateTickerCallback(rAssetID : TAssetIDRec;
                                     pwcDate : PWideChar;
                                      nState : Integer) stdcall;
begin
  GenericLogUpdate(Format('TChangeStateTicker: %s | %s | %s',[rAssetId.pchTicker, pwcDate, GetEnumName(TypeInfo(TAssetStateType),nState)]));
end;

procedure AdjustHistoryCallback                            (rAssetID : TAssetIDRec;
                                                              sValue : Double;
          strAdjustType, strObserv, dtAjuste, dtDeliber, dtPagamento : PwideChar;
                                              nAffectPrice : Integer) stdcall;
begin
  GenericLogUpdate(Format('TAdjustHistoryCallback: %s | %n | %s | %s | %d',[rAssetId.pchTicker, sValue, strAdjustType, strObserv, nAffectPrice]));
end;

procedure AdjustHistoryCallbackV2                       (rAssetID : TAssetIDRec;
                                                            dValue : Double;
        strAdjustType, strObserv, dtAjuste, dtDeliber, dtPagamento : PwideChar;
                                                            nFlags : Cardinal;
                                                             dMult : Double) stdcall;
begin
  GenericLogUpdate(Format('TAdjustHistoryCallbackV2: %s | %n | %s | %s | %d | %n',[rAssetId.pchTicker, dValue, strAdjustType, strObserv, nFlags, dMult]));
end;

procedure TheoreticalPriceCallback(rAssetID : TAssetIDRec;
                           sTheoreticalPrice : Double;
                             nTheoreticalQtd : Int64) stdcall;
begin
  GenericLogUpdate(Format('TTheoreticalPriceCallback: %s | %n | %d',[rAssetId.pchTicker, sTheoreticalPrice, nTheoreticalQtd]));
end;

procedure ChangeCotationCallback(rAssetID   : TAssetIDRec;
                          pwcDate   : PWideChar;
                       nTradeNumber : Cardinal;
                             sPrice : Double) stdcall;
begin
  GenericLogUpdate(Format('TChangeCotationCallback: %s | %s | %n',[rAssetId.pchTicker, pwcDate, sPrice]));
end;

procedure HistoryCallbackV2                                                  (rAssetID : TAssetIDRec;
                            nCorretora, nQtd, nTradedQtd, nLeavesQtd, nSide, nValidity : Integer;
                                                          sPrice, sStopPrice, sAvgPrice : Double;
                                                                              nProfitID : Int64;
                                            TipoOrdem, Conta, Titular, ClOrdID, Status,
                                              Date, LastUpdate, CloseDate, ValidityDate : PWideChar) stdcall;
begin
  GenericLogUpdate(Format('THistoryCallbackV2: %s | %d | %d | %n | %s | %s | %s', [rAssetId.pchTicker, nTradedQtd, nSide, sPrice, Conta, ClOrdId, Status] ));
end;

procedure OrderChangeCallbackV2                                              (rAssetID : TAssetIDRec;
                            nCorretora , nQtd, nTradedQtd, nLeavesQtd, nSide, nValidity : Integer;
                                                          sPrice, sStopPrice, sAvgPrice : Double;
                                                                              nProfitID : Int64;
                                      TipoOrdem, Conta, Titular, ClOrdID, Status, Date,
                                      LastUpdate, CloseDate, ValidityDate, TextMessage : PWideChar) stdcall;
begin
  GenericLogUpdate(Format('TOrderChangeCallbackV2: %s | %s | %s | %s | %s | %s', [rAssetID.pchTicker, ClOrdId, Conta, Status, TextMessage, TipoOrdem]));
end;

end.
