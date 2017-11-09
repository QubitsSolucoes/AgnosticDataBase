unit UTesteArrayAssoc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    btnArray: TButton;
    procedure btnArrayClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  ArrayAssoc, ArrayAssocClass;

{$R *.dfm}

procedure TForm1.btnArrayClick(Sender: TObject);
var
  ArrayAssocBi: TArrayAssocBi;
  VArrayAssoc: IArray;
begin
  // CLASSE ARRAY MULTIDIMENSIONAL
  VArrayAssoc := TArrayAssocClass.Create(
                                         [
                                          'Teste1',
                                          'Teste2',
                                          'Teste3',
                                          'Teste4'
                                         ],
                                         [
                                          TArrayAssocClass.Create(['Teste1',
                                                                   'Teste2'], [TArrayAssocProperty.Create('key1', 55), TArrayAssocProperty.Create('key1', 100)]),
                                          TArrayAssocClass.Create(['Teste2'], [TArrayAssocClass.Create(['Teste3'], [TArrayAssocClass.Create(['Teste4'], [TArrayAssocProperty.Create('key1', 55)])])]),
                                          TArrayAssocClass.Create(['Teste2'], [TArrayAssocProperty.Create('key3', 95)]),
                                          TArrayAssocClass.Create(['Teste4'], [TArrayAssocClass.Create(['Teste2'], [TArrayAssocProperty.Create('key3', 6351651)])])
                                         ]
                                        );

  showmessage(VArrayAssoc['Teste1']['Teste1'].Value);
  showmessage(VArrayAssoc['Teste1']['Teste2'].Value);
  showmessage(VArrayAssoc['Teste2']['Teste2']['Teste3']['Teste4'].Value);
  showmessage(VArrayAssoc['Teste3']['Teste2'].Value);
  showmessage(VArrayAssoc['Teste4']['Teste4']['Teste2'].Value);

  

  //TESTE TARRAYASSOCBI
  ArrayAssocBi['Item1']['Teste'] := 'Primeira1';
  ArrayAssocBi['Item2']['Teste2'] := 'PrimeiraT3';
  ArrayAssocBi['String 2']['teste3'] := 'Segunda4';
  ArrayAssocBi['String 2']['teste4'] := 'SegundaTC6';
  ArrayAssocBi['String 4']['teste4'] := 'Terceira7';
  ArrayAssocBi['Item5']['Teste5'] := 'Terceira8';

  
  ArrayAssocBi['Item1']['Teste'] := 'Segunda2';   
  ArrayAssocBi['String 2']['teste3'] := 'SegundaT5';

  Showmessage(ArrayAssocBi['Item1']['Teste']);
  Showmessage(ArrayAssocBi['Item1']['Teste']);
  Showmessage(ArrayAssocBi['Item2']['Teste2']);  
  Showmessage(ArrayAssocBi['String 2']['teste3']); 
  ShowMessage(ArrayAssocBi['String 2']['teste4']);
  Showmessage(ArrayAssocBi['String 4']['teste4']);
  Showmessage(ArrayAssocBi['Item5']['Teste5']);
end;

end.
