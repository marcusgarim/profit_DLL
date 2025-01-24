//******************************************************************************
//
//       Nome: ConnectorUtilsU
//  Descrição: Funções auxiliares para conversão de objetos/registros do Profit
//             para registros da interface (que utilizam estruturas simplifica-
//             das)
//
//    Criação: 14/08/2017  v1.0.1.0  Rafael Koch Peres
// Modificado:
//
//******************************************************************************
unit ConnectorUtilsU;

{$I KoT.inc}

interface

uses
  ConnectorInterfaceU,
  AssetDataTypesU;

function GetAssetID(const i_tAssetID : TAssetIdentifier; out o_recAssetID : TAssetIDRec) : LongBool; overload;
function GetAssetID(const i_recAssetID : TAssetIDRec; out o_tAssetID : TAssetIdentifier) : LongBool; overload;

function GetAssetID(const a_AssetID : TAssetIdentifier) : TAssetIDRec; overload;
function GetAssetID(const a_AssetID : TAssetIDRec) : TAssetIdentifier; overload;

function DateTimeToDLLString(const a_dtDate : TDateTime) : String; inline

implementation

uses
  System.SysUtils;

const
  EMPTY_ASSET_ID : TAssetIDRec = (pchTicker: ''; pchBolsa: ''; nFeed: 0);

//******************************************************************************
//
//       Nome: GetAssetID
//  Descrição: Converte um Profit TAssetIdentifier para um record TAssetIDRec
//             para a DLL
//
//    Criação: 14/08/2017  v1.0.1.0  Rafael Koch Peres
// Modificado:
//
//******************************************************************************
function GetAssetID(const i_tAssetID : TAssetIdentifier; out o_recAssetID : TAssetIDRec) : LongBool; overload;
begin
  o_recAssetID := EMPTY_ASSET_ID;

  o_recAssetID.pchTicker := PWideChar(i_tAssetID.strTicker);
  o_recAssetID.pchBolsa  := PWideChar(BolsaToString(i_tAssetID.nBolsa));
  o_recAssetID.nFeed     := Ord(i_tAssetID.ftFeed);

  Result := True;
end;

//******************************************************************************
//
//       Nome: GetAssetID
//  Descrição: Converte um record TAssetIDRec para um  Profit TAssetIdentifier
//
//    Criação: 14/08/2017  v1.0.1.0  Rafael Koch Peres
// Modificado:
//
//******************************************************************************
function GetAssetID(const i_recAssetID : TAssetIDRec; out o_tAssetID : TAssetIdentifier) : LongBool; overload;
begin
  o_tAssetID.strTicker := String(i_recAssetID.pchTicker);
  o_tAssetID.nBolsa    := BolsaFromString(String(i_recAssetID.pchBolsa));
  o_tAssetID.ftFeed    := FeedType(i_recAssetID.nFeed);

  Result := True;
end;

function GetAssetID(const a_AssetID : TAssetIdentifier) : TAssetIDRec;
begin
  Result := EMPTY_ASSET_ID;

  Result.pchTicker := PWideChar(a_AssetID.strTicker);
  Result.pchBolsa  := PWideChar(BolsaToString(a_AssetID.nBolsa));
  Result.nFeed     := Ord(a_AssetID.ftFeed);
end;

function GetAssetID(const a_AssetID : TAssetIDRec) : TAssetIdentifier;
begin
  Result.strTicker := String(a_AssetID.pchTicker);
  Result.nBolsa    := BolsaFromString(String(a_AssetID.pchBolsa));
  Result.ftFeed    := FeedType(a_AssetID.nFeed);
end;

function DateTimeToDLLString(const a_dtDate : TDateTime) : String;
begin
  Result := FormatDateTime(c_strDateFormat, a_dtDate);
end;

end.
