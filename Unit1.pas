unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.AddressBook.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FMX.AddressBook,

  System.IOUtils, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.StdCtrls,
  FMX.ListView, FMX.Controls.Presentation, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope;

type
  TForm1 = class(TForm)
    AddressBook1: TAddressBook;
    FDConn: TFDConnection;
    QryContatos: TFDQuery;
    QryContatosID: TIntegerField;
    QryContatosFIRSTNAME: TStringField;
    QryContatosLASTNAME: TStringField;
    dtsContatos: TDataSource;
    QryEmails: TFDQuery;
    QryEmailsID: TFDAutoIncField;
    QryEmailsID_CONTATO: TIntegerField;
    QryEmailsEMAIL_WORK: TStringField;
    QryEmailsEMAIL_HOME: TStringField;
    QryEmailsEMAIL_OTHER: TStringField;
    QryEmailsTIPO_EMAIL: TStringField;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    QryAux1: TFDQuery;
    QryAux2: TFDQuery;
    ToolBar1: TToolBar;
    Button1: TButton;
    ListView1: TListView;
    Label1: TLabel;
    ListView2: TListView;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    procedure FDConnBeforeConnect(Sender: TObject);
    procedure AddressBook1PermissionRequest(ASender: TObject;
      const AMessage: string; const AAccessGranted: Boolean);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure PreencherContatos;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.AddressBook1PermissionRequest(ASender: TObject;
  const AMessage: string; const AAccessGranted: Boolean);
begin
  if AAccessGranted then
    PreencherContatos;
end;

procedure TForm1.FDConnBeforeConnect(Sender: TObject);
begin
  FDConn.Params.Values['Database'] :=
    TPath.Combine(TPath.GetDocumentsPath, 'TAddressBook.sqlite');
  FDConn.Params.Values['OpenMode'] := 'ReadWrite';
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  AddressBook1.RequestPermission;
end;

procedure TForm1.PreencherContatos;
{$REGION 'INSERTS'}
const
  INS_CONTATO =
    'INSERT INTO CONTATOS ' +
    '(                    ' +
    '   ID         ,      ' +
    '   FIRSTNAME  ,      ' +
    '   LASTNAME          ' +
    ')                    ' +
    'VALUES               ' +
    '(                    ' +
    '   :ID         ,     ' +
    '   :FIRSTNAME  ,     ' +
    '   :LASTNAME         ' +
    ');                   ';

  INS_EMAILS =
    'INSERT INTO EMAILS   ' +
    '(                    ' +
    '   TIPO_EMAIL ,      ' +
    '   ID_CONTATO ,      ' +
    '   EMAIL_WORK        ' +
    ')                    ' +
    'VALUES               ' +
    '(                    ' +
    '   :TIPO_EMAIL ,     ' +
    '   :ID_CONTATO ,     ' +
    '   :EMAIL_WORK       ' +
    ');                   ';
{$ENDREGION}
var
  Contatos  : TAddressBookContacts;
  Emails    : TContactEmails;
  EmailCont : TContactEmail;
  Address   : TContactAddresses;
  I         : Integer;
  J         : Integer;
  X         : Integer;
  arrSize   : Integer;
begin
  try
    QryAux1.Active := False;
    QryAux1.SQL.Clear;
    QryAux1.SQL.Text := 'DELETE FROM CONTATOS';
    QryAux1.ExecSQL;

    QryAux2.Active := False;
    QryAux2.SQL.Clear;
    QryAux2.SQL.Text := 'DELETE FROM EMAILS';
    QryAux2.ExecSQL;

    QryAux1.Active := False;
    QryAux1.SQL.Clear;
    QryAux1.SQL.Text := INS_CONTATO;

    (*
      TAddressBookContact(Contatos.Items[I]).ID
      TAddressBookContact(Contatos.Items[I]).DisplayName
      TAddressBookContact(Contatos.Items[I]).FirstName
      TAddressBookContact(Contatos.Items[I]).MiddleName
      TAddressBookContact(Contatos.Items[I]).LastName
    TAddressBookContact(Contatos.Items[I]).Prefix
    TAddressBookContact(Contatos.Items[I]).Suffix
      TAddressBookContact(Contatos.Items[I]).NickName
    TAddressBookContact(Contatos.Items[I]).FirstNamePhonetic
    TAddressBookContact(Contatos.Items[I]).MiddleNamePhonetic
    TAddressBookContact(Contatos.Items[I]).LastNamePhonetic
    TAddressBookContact(Contatos.Items[I]).Organization
    TAddressBookContact(Contatos.Items[I]).JobTitle
    TAddressBookContact(Contatos.Items[I]).Department
      TAddressBookContact(Contatos.Items[I]).Photo //TBitmapSurface
      TAddressBookContact(Contatos.Items[I]).PhotoThumbnail //TBitmapSurface
    TAddressBookContact(Contatos.Items[I]).Department
      TAddressBookContact(Contatos.Items[I]).EMails //Coleção Ok
      TAddressBookContact(Contatos.Items[I]).Birthday
    TAddressBookContact(Contatos.Items[I]).Note
    TAddressBookContact(Contatos.Items[I]).Addresses //Coleção
    TAddressBookContact(Contatos.Items[I]).SocialProfiles //Coleção
    TAddressBookContact(Contatos.Items[I]).RelatedNames //Coleção
    TAddressBookContact(Contatos.Items[I]).URLs //Coleção
    *)

    Contatos := TAddressBookContacts.Create;
    AddressBook1.AllContacts(AddressBook1.DefaultSource, Contatos);
    try
      for I := 0 to Pred(Contatos.Count) do
      begin
        QryAux1.ParamByName('ID').AsIntegers[0]         := TAddressBookContact(Contatos.Items[I]).ID;
        //QryAux1.ParamByName('DISPLAYNAME').AsStrings[I] := TAddressBookContact(Contatos.Items[I]).DisplayName;
        QryAux1.ParamByName('FIRSTNAME').AsStrings[0]   := TAddressBookContact(Contatos.Items[I]).FirstName;
        QryAux1.ParamByName('LASTNAME').AsStrings[0]    := TAddressBookContact(Contatos.Items[I]).LastName;
        //QryAux1.ParamByName('LASTNAME').AsStrings[I]    := TAddressBookContact(Contatos.Items[I]).NickName;
        QryAux1.Execute(1, 0);

        QryAux2.Active := False;
        QryAux2.SQL.Clear;
        QryAux2.SQL.Text := INS_EMAILS;

        Emails  := TContactEmails.Create;
        arrSize := TAddressBookContact(Contatos.Items[I]).EMails.Count;
        QryAux2.Params.ArraySize := arrSize;
        for J := 0 to Pred(TAddressBookContact(Contatos.Items[I]).EMails.Count) do
        begin
          QryAux2.ParamByName('ID_CONTATO').AsIntegers[J] := TAddressBookContact(Contatos.Items[I]).ID;

          case TContactEmail(TAddressBookContact(Contatos.Items[I]).EMails[J]).LabelKind of
            TContactEmail.TLabelKind.Work   : QryAux2.ParamByName('TIPO_EMAIL').AsStrings[J]  := 'Trabalho';
            TContactEmail.TLabelKind.Home   : QryAux2.ParamByName('TIPO_EMAIL').AsStrings[J]  := 'Casa';
            TContactEmail.TLabelKind.Other  : QryAux2.ParamByName('TIPO_EMAIL').AsStrings[J]  := 'Outros';
            TContactEmail.TLabelKind.Custom : QryAux2.ParamByName('TIPO_EMAIL').AsStrings[J]  := 'Custom';
          else
            QryAux2.ParamByName('TIPO_EMAIL').AsStrings[J]  := 'Unknown';
          end;

          QryAux2.ParamByName('EMAIL_WORK').AsStrings[J]  := TAddressBookContact(Contatos.Items[I]).EMails[J].Email;
        end;

        if arrSize > 0 then
          QryAux2.Execute(arrSize, 0);
      end;
    finally

    end;
    QryContatos.Open();
    QryEmails.Open();
  finally
    Contatos.DisposeOf;
    Emails.DisposeOf;
  end;
end;

end.
