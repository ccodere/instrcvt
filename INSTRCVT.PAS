{************************************************}
{   Simple FM Instrument Converter.              }
{   Freeware  1995 by Carl Eric Codere.          }
{   Montreal, Canada - September 1995.           }
{************************************************}
{ Contact me at: carl.codere@evening.magicnet.com         }
{  From 1995-1998 you can also contact me at:             }
{      cecodere@andrew.sca.usherb.ca  (preferred method)  }


Program Instruments;
(* Conditions for use of this source code:                                *)
(*      - No re-release of this or the modified source code is done.      *)
(*      - Proper credit is given to the author of these routines.         *)
(*      - That I be notified of any bugfixes / major upgrades.            *)

{ Converts from the following formats: }
{ Adlib Sound Tracker          -> .INS }
  { Refers to Version 1.0 and 2.0 of SP! Adlib Tracker (by Erik Pojar/SP!) }
{ Sound Blaster Instrument     -> .SBI }
{ Adlib Instrument             -> .INS }
  { 54 byte versions only! }


{ 11/07/95 }
{ $ BUGFIX                                                              }
{     - Removed a bug in the SBI convert routine                        }
{     - Removed a bug in the Adlib Instrument conversion routine        }
{        15 = 15 - Register.                                            }
{ 12/28/95                                                              }
{     - Removed a bug in the Tracker Instruments registers              }
{     - Removed a bug in the Adlib Additive Sythesis record             }



{$V-}
{$R+}
{$Q+}
Uses Objects,Crt,DOS;

Const
 { Type of conversion to do }
 SBIfile     = 1;         (* Convert to Creative labs SBI File         *)
 INSfile     = 2;         (* Convert to Adlib Corp.   INS File         *)
 TrackerFile = 3;         (* Convert to Tracker INS file               *)

 { File sizes for each type of file }
 { This is done for checking        }
 Tracker1Size = 27;
 Tracker2Size = 31;
 INSSize      = 54;
 SBISize      = 52;




Type



  { Sound Blaster Standard Instrument  .SBI}
 TSBIInstrument = Record
  Id: Array[0..3] of Char;
  Name: Array[1..32] of Char;
  ModulatorChar: Byte;      (* Modulator Characteristic *)
  CarrierChar: Byte;        (* Carrier Characteristic   *)
  ModScalingOutput: Byte;
  CarScalingOutput: Byte;
  ModAttackDecay: Byte;
  CarAttackDecay: Byte;
  ModSustainRelease: Byte;
  CarSustainRelease: Byte;
  ModWaveSelect: Byte;
  CarWaveSelect: Byte;
  FeedBackConnection: Byte;
  Reserved: Array[1..5] of Byte;
end;

 { Adlib Sound Tracker Instrument format .INS                 }
  TTracker1Instrument = Record
   FeedBackConnection: Byte;
   ModulatorChar: Byte;
   CarrierChar: Byte;
   ModAttackDecay: Byte;
   CarAttackDecay: Byte;
   ModSustainRelease: Byte;
   CarSustainRelease: Byte;
   ModWaveSelect: Byte;
   CarWaveSelect: Byte;
   ModScalingOutput: Byte;
   CarScalingOutput: Byte;
   ArpeggioStart: Byte;
   ArpeggioSpeed: Byte;
   CurrentPos: Byte;
   SpeedCount: Byte;
   Name: Array[0..11] of Char;
  end;

  TTracker2Instrument = Record
   FeedBackConnection: Byte;
   ModulatorChar: Byte;
   CarrierChar: Byte;
   ModAttackDecay: Byte;
   CarAttackDecay: Byte;
   ModSustainRelease: Byte;
   CarSustainRelease: Byte;
   ModWaveSelect: Byte;
   CarWaveSelect: Byte;
   ModScalingOutput: Byte;
   CarScalingOutput: Byte;
   ArpeggioStart: Byte;
   ArpeggioSpeed: Byte;
   CurrentPos: Byte;
   SpeedCount: Byte;
   Name: Array[0..15] of Char;
  end;


 { Adlib Standard Instrument Format  .INS}
 TINSInstrument = Record
  Mode: Byte;
  Number: Byte;
  ModKeyScaling: Byte;       { Registers $40-$55 }
  Res1: Byte;
  ModMultiple: Byte;         { Registers $20-$35 }
  Res2: Byte;
  Feedback: Byte;            { Registers $C0-$C8 }
  Res3: Byte;
  ModAttackRate: Byte;       { Registers $60-$75 }
  Res4: Byte;
  ModSustainLevel: Byte;     { Registers $80-$95  }
  Res5: Byte;
  ModSustaining: Boolean;    { Registers $20-$35  }
  Res6: Byte;
  ModDecayRate: Byte;        { Registers $60-$75 }
  Res7: Byte;
  ModReleaseRate: Byte;      { Registers $80-$95 }
  Res8: Byte;
  ModOutputLevel: Byte;      { Registers $40-$55 }
  Res9: Byte;
  ModAM: Boolean;            { Registers $20-$35 }
  Res10: Byte;
  ModVibrato: Boolean;       { Registers $20-$35 }
  Res11: Byte;
  ModKSR: Boolean;           { Registers $20-$35 }
  Res12: Byte;
  Connection:Boolean;        { Registers $C0-$C8 }
  Res24: Byte;

  CarKeyScaling: Byte;       { Registers $40-$55 }
  Res13: Byte;
  CarMultiple: Byte;         { Registers $20-$35 }
  Res14: Byte;
  Unused: Byte;
  Res15: Byte;
  CarAttackRate: Byte;       { Registers $60-$75 }
  Res16: Byte;
  CarSustainLevel: Byte;     { Registers $80-$95 }
  Res17: Byte;
  CarSustaining: Boolean;    { Registers $20-$35 }
  Res18: Byte;
  CarDecayRate: Byte;        { Registers $60-$75 }
  Res19: Byte;
  CarReleaseRate: Byte;      { Registers $80-$95 }
  Res20: Byte;
  CarOutputLevel: Byte;      { Registers $40-$55 }
  Res21: Byte;
  CarAM: Boolean;            { Registers $20-$35 }
  Res22: Byte;
  CarVibrato: Boolean;       { Registers $20-$35 }
  Res23: Byte;
  CarKSR: Boolean;           { Registers $20-$35 }

  Reserved: Byte;
  ModWaveSelect: Byte;       { Registers $E0-$F5 }
  CarWaveSelect: Byte;       { Registers $E0-$F5 }
 end;

 { This is the correct Adlib Card register order }
 { all are converted to this intermediary form   }
 { when converting to another format.            }
 TRegister = Record
  Name: Array[0..15] of Char;
  ModulatorChar: Byte;      (* Modulator Characteristic *)
  CarrierChar: Byte;        (* Carrier Characteristic   *)
  ModScalingOutput: Byte;
  CarScalingOutput: Byte;
  ModAttackDecay: Byte;
  CarAttackDecay: Byte;
  ModSustainRelease: Byte;
  CarSustainRelease: Byte;
  FeedBackConnection: Byte;
  ModWaveSelect: Byte;
  CarWaveSelect: Byte;
 end;


(*************************************************************************)
(*                        GENERAL USAGE ROUTINES                         *)
(*************************************************************************)


Procedure UpStr(var S: String);
 (* 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)
 (* *  PROCEDURE UpStr;                                        * *)
 (* *   This procedure converts all characters of the string   * *)
 (* *   to uppercase.                                          * *)
 (* *  Var S:String -> String to modify.                       * *)
 (* 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)
Var
  i:Byte;
Begin
  For I := 1 to Length(S) do
      S[I] := UpCase(S[I]);
End;

Function VerifyFilePresence(Const FName:FNameStr):Boolean;
 (* 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)
 (* *  FUNCTION VerifyFilePresence: Boolean;                   * *)
 (* *   Verifies if the file passed in S is in the current     * *)
 (* *   active directory. If not returns False, otherwise      * *)
 (* *   true.                                                  * *)
 (* *   S: FNameStr -> Full Filename to verify.                * *)
 (* 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)
Var
 AFileRecord: SearchRec;
Begin
  VerifyFilePresence:=False;
  FindFirst(FName,$3F,AFileRecord);
  If DosError = 0 then
    VerifyFilePresence:=True
end;

(*************************************************************************)
(* Create a stream error procedure which will be called on error of the  *)
(* stream. Will Terminate executing program, as well as display info     *)
(* on the type of error encountered.                                     *)
(*************************************************************************)
Procedure StreamErrorProcedure(Var S: TStream); FAR;
Begin
 If S.Status = StError then
 Begin
  WriteLn('ERROR: General Access failure. Halting');
  Halt(1);
 end;
 If S.Status = StInitError then
 Begin
  WriteLn('ERROR: Cannot Init Stream. Halting');
  { SPECIFIC TO DOS STREAMS }
  Case S.ErrorInfo of
  2: WriteLn('File not found.');
  3: WriteLn('Path not found.');
  5: Writeln('Access denied.');
  end;
  Halt(1);
 end;
 If S.Status = StReadError then
 Begin
  WriteLn('ERROR: Read beyond end of Stream. Halting');
  Halt(1);
 end;
 If S.Status = StWriteError then
 Begin
  WriteLn('ERROR: Cannot expand Stream. Halting');
  Halt(1);
 end;
 If S.Status = StGetError then
 Begin
  WriteLn('ERROR: Get of Unregistered type. Halting');
  Halt(1);
 end;
 If S.Status = StPutError then
 Begin
  WriteLn('ERROR: Put of Unregistered type. Halting');
  Halt(1);
 end;
end;

(*************************************************************************)
(*                   PROGRAM SPECIFIC ROUTINES                           *)
(*************************************************************************)

{ Convert the values of the Adlib format to the direct output register }
{ format which will be used directly with the card.                    }
Procedure convertINStoRegister(Ins: TINSInstrument; Var Out: TRegister);
Begin
 { Undefined values should be put in correct format , only applies to }
 { Adlib INS format for percussive instruments.                       }
 { THERE MAY BE BUGS: I checked and BOOLEAN up to date in the instruments }
 { can only get the 0 and 1 value just like pascal.                       }
 If Ins.Mode <> 0 then
 Begin
  If Ins.Modmultiple > $0F then Ins.ModMultiple := 0;
  If Ins.ModKeyScaling > $03 then Ins.ModKeyScaling := 0;
  If Ins.ModOutputLevel > $3F then Ins.ModOutputLevel := 0;
  If Ins.ModSustainLevel >$0F then Ins.ModSustainLevel := 0;
  If Ins.ModReleaseRate > $0F then Ins.ModReleaseRate := 0;
  If Ins.ModAttackRate > $0F then Ins.ModAttackRate := 0;
  If Ins.ModDecayRate > $0F then Ins.ModDecayRate := 0;
  If Ins.CarMultiple > $0F then Ins.CarMultiple := 0;
  If Ins.CarKeyScaling > $03 then Ins.CarKeyScaling := 0;
  If Ins.CarOutputLevel > $3F then Ins.CarOutputLevel := 0;
  If Ins.CarSustainLevel >$0F then Ins.CarSustainLevel := 0;
  If Ins.CarReleaseRate > $0F then Ins.CarReleaseRate := 0;
  If Ins.CarAttackRate > $0F then Ins.CarAttackRate := 0;
  If Ins.CarDecayRate > $0F then Ins.CarDecayRate := 0;

  If Byte(Ins.CarKSR) > 1 then Ins.CarKSR := FALSE;
  If Byte(Ins.CarVibrato) > 01 then Ins.CarVibrato := FALSE;
  If Byte(Ins.CarAM) > 01 then Ins.CarAM := FALSE;
  If Byte(Ins.CarSustaining) > 01 then ins.CarSustaining := FALSE;
  If Byte(Ins.ModKSR) > 01 then Ins.ModKSR := FALSE;
  If Byte(Ins.ModVibrato) > 01 then Ins.ModVibrato := FALSE;
  If Byte(Ins.ModAM) > 01 then Ins.ModAM := FALSE;
{  If Byte(Ins.ModSustaining) > 01 then ins.ModSustaining := FALSE;}

 end;

 Out.ModulatorChar :=   Ins.ModMultiple +  Byte(Ins.ModVibrato) SHL 6 +
   Byte(Ins.ModKSR) SHL 4 + Byte(Ins.ModAM) SHL 7 + Byte(Ins.ModSustaining)
   SHL 5;
 Out.CarrierChar :=   Ins.CarMultiple +  Byte(Ins.CarVibrato) SHL 6 +
   Byte(Ins.CarKSR) SHL 4 + Byte(Ins.CarAM) SHL 7 + Byte(Ins.CarSustaining)
   SHL 5;
 Out.ModScalingOutput := Ins.ModKeyScaling SHL 6 + Ins.ModOutputLevel;
 Out.CarScalingOutput := Ins.CarKeyScaling SHL 6 + Ins.CarOutputLevel;

 Out.ModAttackDecay :=  Ins.ModAttackRate SHL 4 + Ins.ModDecayRate;
 Out.CarAttackDecay :=  Ins.CarAttackRate SHL 4 + Ins.CarDecayRate;

 Out.ModSustainRelease := (Ins.ModSustainLevel) SHL 4 + Ins.ModReleaseRate;
 Out.CarSustainRelease := (Ins.CarSustainLevel) SHL 4 + Ins.CarReleaseRate;

 { The values are inverted in the instrument format }
 If Ins.Connection = TRUE
  then Ins.Connection := FALSE
 else
    Ins.Connection := TRUE;

 Out.FeedbackConnection := Ins.Feedback SHL 1 + Byte(Ins.Connection);

 Out.ModWaveSelect := Ins.ModWaveSelect;
 Out.CarWaveSelect := Ins.CarWaveSelect;
end;



{ Convert Internal Register format to Adlib Tracker format }
Procedure ConvertRegisterToTracker(Const Inp: TRegister;
    Var Out: TTracker2Instrument);
Var
 i: Byte;
Begin
 For i:= 0 to 15 do
   Out.Name[i] := Inp.Name[i];
  Out.FeedbackConnection:= Inp.FeedBackConnection;
  Out.ModulatorChar:=    Inp.ModulatorChar;
  Out.CarrierChar:=    Inp.CarrierChar;
  Out.ModAttackDecay:=   Inp.ModAttackDecay;
  out.CarAttackDecay:=   Inp.CarAttackDecay;
  Out.ModSustainRelease:=Inp.ModSustainRelease;
  Out.CarSustainRelease:=Inp.CarSustainRelease;
  Out.ModWaveSelect:=    Inp.ModWaveSelect;
  Out.CarWaveSelect:=    Inp.CarWaveSelect;
  Out.ModScalingoutput:= Inp.ModScalingOutput;
  Out.CarScalingOutput:= Inp.CarScalingoutput;
  Out.ArpeggioStart:= 0;
  Out.ArpeggioSpeed:= 0;
  Out.CurrentPos:= 0;
  Out.SpeedCount:= 0;
end;

{ Convert Internal Register Format to SBI Format }
Procedure ConvertRegisterToSBI(Const inp: TRegister;
  Var Out: TSBIInstrument);
Var
 i: Byte;
Begin
  Out.Id := 'SBI'+Chr($1A);
  For i:=1 to 11 do
    Out.Name[i] := Inp.Name[i];
  Out.ModulatorChar:= Inp.ModulatorChar;
  Out.CarrierChar :=  Inp.CarrierChar;
  Out.ModScalingOutput := Inp.ModScalingoutput;
  Out.CarScalingOutput := Inp.CarScalingOutput;
  Out.ModAttackDecay :=   Inp.ModAttackDecay;
  Out.CarAttackDecay :=   Inp.CarAttackDecay;
  Out.ModSustainRelease :=Inp.ModSustainRelease;
  Out.CarSustainRelease :=Inp.CarSustainRelease;
  Out.ModWaveSelect :=    Inp.ModWaveSelect;
  Out.CarWaveSelect :=    Inp.CarWaveSelect;
  Out.FeedBackConnection :=  Inp.FeedbackConnection;
  For i:=1 to 5 do
   Out.Reserved[i] := 0;
end;

{ Convert SBI Instrument to Internal Register format }
Procedure ConvertSBIToRegister(Const Inp: TSBIInstrument; Var Out:TRegister);
Begin
  Out.ModulatorChar:= Inp.ModulatorChar;
  Out.CarrierChar :=  Inp.CarrierChar;
  Out.ModScalingOutput := Inp.ModScalingoutput;
  Out.CarScalingOutput := Inp.CarScalingOutput;
  Out.ModAttackDecay :=   Inp.ModAttackDecay;
  Out.CarAttackDecay :=   Inp.CarAttackDecay;
  Out.ModSustainRelease :=Inp.ModSustainRelease;
  Out.CarSustainRelease :=Inp.CarSustainRelease;
  Out.ModWaveSelect :=    Inp.ModWaveSelect;
  Out.CarWaveSelect :=    Inp.CarWaveSelect;
  Out.FeedBackConnection :=  Inp.FeedbackConnection;
end;

{ Convert Adlib Tracker to Internal Register Format Version 1.0+ }
Procedure ConvertTrackerOneToRegister(const inp: TTracker1Instrument;
 Var Out: TRegister);
Begin
  Out.ModulatorChar:= Inp.ModulatorChar;
  Out.CarrierChar :=  Inp.CarrierChar;
  Out.ModScalingOutput := Inp.ModScalingoutput;
  Out.CarScalingOutput := Inp.CarScalingOutput;
  Out.ModAttackDecay :=   Inp.ModAttackDecay;
  Out.CarAttackDecay :=   Inp.CarAttackDecay;
  Out.ModSustainRelease :=Inp.ModSustainRelease;
  Out.CarSustainRelease :=Inp.CarSustainRelease;
  Out.ModWaveSelect :=    Inp.ModWaveSelect;
  Out.CarWaveSelect :=    Inp.CarWaveSelect;
  Out.FeedBackConnection :=  Inp.FeedbackConnection;
end;

{ Convert Adlib Tracker to Internal Register Format Version 2.0+ }
Procedure ConvertTrackerTwoToRegister(const inp: TTracker2Instrument;
 Var Out: TRegister);
Begin
  Out.ModulatorChar:= Inp.ModulatorChar;
  Out.CarrierChar :=  Inp.CarrierChar;
  Out.ModScalingOutput := Inp.ModScalingoutput;
  Out.CarScalingOutput := Inp.CarScalingOutput;
  Out.ModAttackDecay :=   Inp.ModAttackDecay;
  Out.CarAttackDecay :=   Inp.CarAttackDecay;
  Out.ModSustainRelease :=Inp.ModSustainRelease;
  Out.CarSustainRelease :=Inp.CarSustainRelease;
  Out.ModWaveSelect :=    Inp.ModWaveSelect;
  Out.CarWaveSelect :=    Inp.CarWaveSelect;
  Out.FeedBackConnection :=  Inp.FeedbackConnection;
end;


{ Convert Internal Register format to Adlib Ins Format }
Procedure ConvertRegisterToINS(Const Inp: TRegister;
 Var Out: TINSInstrument);
Begin
  { Only melodic mode instruments are converted }
  Out.Mode :=  0;
  Out.Number := 0;

  { Registers $20-$35 }
  Out.ModMultiple :=  inp.ModulatorChar  AND $0F;
  Out.ModSustaining:= Boolean((inp.ModulatorChar AND $20) SHR 5);
  Out.ModAM:=         Boolean((Inp.ModulatorChar AND $80) SHR 7);
  Out.ModVibrato:=    Boolean((Inp.ModulatorChar AND $40) SHR 6);
  Out.ModKSR:=        Boolean((Inp.ModulatorChar AND $10) SHR 4);

  { Registers $40-$55 }
  Out.ModOutputLevel := Inp.ModScalingOutput AND $C3F;
  Out.ModKeyScaling :=  (Inp.ModScalingOutput AND $C0) SHR 6;

  { Registers $60-$75 }
  Out.ModAttackRate := (Inp.ModAttackDecay AND $F0) SHR 4;
  Out.ModDecayRate :=  Inp.ModAttackDecay AND $0F;

  { Registers $80-$95 }
  Out.ModSustainLevel :=  (Inp.ModsustainRelease AND $F0) SHR 4;
  { Convert to correct adlib format }
  Out.ModSustainLevel := Out.ModSustainLevel;
  Out.ModReleaseRate :=   Inp.ModsustainRelease AND $0F;

  Out.Feedback :=  (Inp.FeedBackConnection AND $FE) SHR 1;
  Out.Connection:=  Boolean(Inp.FeedBackConnection AND $01);


  Out.Res1 := 0;
  Out.Res2 := 0;
  Out.Res3 := 0;
  Out.Res4 := 0;
  Out.Res5 := 0;
  Out.Res6 := 0;
  Out.Res7 := 0;
  Out.Res8 := 0;
  Out.Res9 := 0;
  Out.Res10 := 0;
  Out.Res11 := 0;
  Out.Res12 := 0;
  Out.Res24 := 0;

  { Registers $20-$35 }
  Out.CarMultiple :=  inp.CarrierChar  AND $0F;
  Out.CarSustaining:= Boolean((inp.CarrierChar AND $20) SHR 5);
  Out.CarAM:=         Boolean((Inp.CarrierChar AND $80) SHR 7);
  Out.CarVibrato:=    Boolean((Inp.CarrierChar AND $40) SHR 6);
  Out.CarKSR:=        Boolean((Inp.CarrierChar AND $10) SHR 4);

  { Registers $40-$55 }
  Out.CarOutputLevel := Inp.CarScalingOutput AND $3F;
  Out.CarKeyScaling :=  (Inp.CarScalingOutput AND $C0) SHR 6;

  { Registers $60-$75 }
  Out.CarAttackRate := (Inp.CarAttackDecay AND $F0) SHR 4;
  Out.CarDecayRate :=  Inp.CarAttackDecay AND $0F;

  { Registers $80-$95 }
  Out.CarSustainLevel :=  (Inp.CarsustainRelease AND $F0) SHR 4;
  { Convert to correct adlib value }
  Out.CarSustainLevel :=   Out.CarSustainLevel;
  Out.CarReleaseRate :=    Inp.CarsustainRelease AND $0F;

  Out.Res13 :=  0;
  Out.Res14 :=  0;
  Out.Unused := 0;
  Out.Res15 :=  0;
  Out.Res16 :=  0;
  Out.Res17 :=  0;
  Out.Res18 :=  0;
  Out.Res19 :=  0;
  Out.Res20 :=  0;
  Out.Res21 :=  0;
  Out.Res22 :=  0;
  Out.Res23 :=  0;

  Out.Reserved :=  0;
  Out.ModWaveSelect := inp.ModWaveSelect;       { Registers $E0-$F5 }
  Out.CarWaveSelect := Inp.CarWaveSelect;       { Registers $E0-$F5 }
end;


Procedure CheckMusicformat(FName: FnameStr; Var S: TStream);
Var
 Extension: String[3];
 Percussive: Boolean;
 SBIID: Array[0..2] of Char;
Begin
 { Get the file name extension }
 Extension := Copy(FName, Length(Fname)-2, 3);
 UpStr(Extension);
 If Extension = 'SBI' then
 Begin
  S.Seek(0);
  S.Read(SBIID, SizeOf(SBIID));
  S.Seek(0);
  If SBiID <> 'SBI' then
  Begin
    WriteLn('Invalid SBI Format');
    Halt(1);
  end
  else
   Exit;
 end;
 If Extension = 'INS' then
 Begin
   If S.GetSize = INSSize then
   Begin
    S.Seek(0);
    S.Read(Percussive, SizeOf(Percussive));
    S.Seek(0);
    If Percussive then
    Begin
     WriteLn('This is Either an Adlib Percussive Instrument, which is not');
     WriteLn('converted, or it is NOT an Adlib Instrument File.          ');
     Halt(1);
    end
    else
      Exit;
   end;
{  If (S.GetSize <> Tracker1Size) OR (S.GetSize <> Tracker2Size) then
  Begin
     WriteLn('Invalid SP! Tracker Instrument Format');
     Halt(1);
  end;}
 end;
end;


Procedure ProcessCommandLine(Var OutType: Byte; Var Infile: String;
 Var OutFile: String);
Var
 Out: String;
 Found: Byte; { Count number where -A is found }
 Index: Byte;
 Ch : Char;
Begin
 { There are three parameters in the Command line, check if this is so. }
 if ParamCount <> 3 then
 Begin
  WriteLn('Quick FM Instrument Converter Version 1.00');
  WriteLn('------------------------------------------');
  WriteLn('  infile.ext   outfile.ext   -Ax');
  WriteLn(' -Ax option tells type of conversion to do');
  WriteLn('   x = 1 -> convert file to SBI format');
  WriteLn('   x = 2 -> convert file to Adlib Instrument format');
  WriteLn('   x = 3 -> convert file to Adlib Tracker format');
  Halt(1);
 end;
 Index := 1;
 Found := 0;
 { Check if one of the parameters contains a - or / character }
 Repeat
  If ((Pos('/',ParamStr(Index))) = 1)  or (Pos('-',ParamStr(Index)) = 1) then
    Found := Index;
  Inc(Index);
 Until (Index > ParamCount) or (found <> 0);
 If Found = 2 then
 Begin
  WriteLn('Write the -Ax options before or after the two filenames');
  Halt(1);
 end;
 Out := ParamStr(Found);
 UpStr(Out);
 Delete(Out,1,1);
 If Length(Out) <> 2 then
 Begin
  WriteLn('Invalid CommandLine');
  Halt(1);
 end;
 If Out = 'A1' then
  OutType :=SBIFile
 else
 If Out = 'A2' then
  OutType :=INSfile
 else
 If Out = 'A3' then
  OutType := TrackerFile
 else
 Begin
  WriteLn('Invalid Command Line');
  Halt(1);
 end;
 { Check if the input file and output file are ok }
 If Found = 1 then
 Begin
  InFile := ParamStr(2);
  OutFile := ParamStr(3);
 end;
 If Found = 3 then
 Begin
  InFile := ParamStr(1);
  OutFile := ParamStr(2);
 end;
  If InFile = OutFile then
  Begin
   WriteLn('Cannot Specify same file as input and output');
   Halt(1);
  end;
  If NOT VerifyFilePresence(InFile) then
  Begin
   WriteLn('Input file not found');
   Halt(1);
  end;
  { No extension was specified }
  If (Pos('.',InFile) = 0) or (Pos('.', OutFile) = 0) then
  Begin
   WriteLn('Extensions were not specified');
   Halt(1);
  end;
  { the file already exists }
  If VerifyFilePresence(OutFile) then
  Begin
    Write('File already exits, overwrite? (Y/N) ');
    Repeat ch:=UpCase(ReadKey) until Ch in ['Y','N'];
    WriteLn(Ch);
    If Ch = 'N' then
     Halt(1);
  end;
end;


{ Process the type of file to convert and convert it }
Procedure Convert(Var InFile: TStream; Var OutFile: Tstream; OutType: Byte);
Var
 SBlasterInstrument: TSBIInstrument;
 AdlibInstrument: TINSInstrument;
 Tracker1Instrument: TTracker1Instrument;
 Tracker2Instrument: TTracker2Instrument;
 Register: TRegister;      { General Register for Adlib           }
Begin
 Case Infile.Getsize of
 SBISize:{ This is a SBI }
     Begin
      Infile.Read(SBlasterInstrument, SizeOf(SblasterInstrument));
      ConvertSBIToRegister(SBlasterInstrument,Register);
      Case OutType of
      SBIFile: Begin
                WriteLn('Nothing to do!');
                Halt(1);
               end;
      INSFile: Begin
                WriteLn('Converting to Adlib format...');
                ConvertRegisterToINS(Register, AdlibInstrument);
                OutFile.Write(AdlibInstrument, SizeOf(AdlibInstrument));
                { Do some range checking of file size just in case }
                If OutFile.GetSize <> InsSize then
                 WriteLn('Unknown Error has occured');
               end;
      TrackerFile:
               Begin
                WriteLn('Converting to Adlib Tracker format...');
                ConvertRegisterToTracker(Register, Tracker2Instrument);
                OutFile.Write(Tracker2Instrument, SizeOf(Tracker2Instrument));
                If OutFile.GetSize <> Tracker2Size then
                  WriteLn('Unknown Error has occured');
               end;
        end;
     end;
 InsSize:{ This is an Adlib INS }
     Begin
       InFile.Read(AdlibInstrument, SizeOf(AdlibInstrument));
       ConvertINSToRegister(AdlibInstrument, Register);
      Case OutType of
      SBIFile: Begin
                WriteLn('Converting to SBI format...');
                ConvertRegisterToSBI(Register, SBlasterInstrument);
                Outfile.Write(SBlasterInstrument, SizeOf(SBlasterInstrument));
                If OutFile.GetSize <> SBISize then
                  WriteLn('Unknown Error has occured');
               end;
      INSFile: Begin
                WriteLn('Nothing to Do!');
                Halt(1);
               end;
      TrackerFile:
               Begin
                WriteLn('Converting to Adlib Tracker format...');
                ConvertRegisterToTracker(Register, Tracker2Instrument);
                OutFile.Write(Tracker2Instrument, SizeOf(Tracker2Instrument));
                If OutFile.GetSize <> Tracker1Size then
                  WriteLn('Unknown Error has occured');
               end;
        end;
     end;
 Tracker1Size, Tracker2Size:{ This is an Adlib tracker }
     Begin
       If Infile.GetSize = Tracker1Size then
       Begin
          InFile.Read(Tracker1Instrument, SizeOf(Tracker1Instrument));
          ConvertTrackerOneToRegister(Tracker1Instrument, Register);
       end
       else
       Begin
          Infile.Read(Tracker2Instrument, SizeOf(Tracker2Instrument));
          ConvertTrackerTwoToRegister(Tracker2Instrument, Register);
       end;
      Case OutType of
      SBIFile: Begin
                WriteLn('Converting to SBI format...');
                ConvertRegisterToSBI(Register, SBlasterInstrument);
                Outfile.Write(SBlasterInstrument, SizeOf(SBlasterInstrument));
                If OutFile.GetSize <> SBISize then
                  WriteLn('Unknown Error has occured');
               end;
      INSFile: Begin
                WriteLn('Converting to Adlib format...');
                ConvertRegisterToINS(Register, AdlibInstrument);
                OutFile.Write(AdlibInstrument, SizeOf(AdlibInstrument));
                { Do some range checking of file size just in case }
                If OutFile.GetSize <> INSSize then
                 WriteLn('Unknown Error has occured');
               end;
      TrackerFile:
               Begin
                WriteLn('Nothing to Do!');
                Halt(1);
               end;
     end;
     end;
  else
   WriteLn('ERROR: Invalid File format detected');
   Halt(1);
  end;
end;


Var
 OutType: Byte;           { Conversion Format type                }
 OutFile: TBufStream;     { Output Stream of Converted Instrument }
 InFile: TBufStream;      { Instrument File to be converted       }
 InPath: String;
 OutPath: String;
Begin
 StreamError:= @StreamErrorProcedure;

 { Check if the commandline is valid }
 ProcessCommandLine(OutType, InPath, OutPath);

 { Initialize input stream }
 InFile.Init(InPath, StOpenRead, 1024);

 { Check if the music format is valid }
 CheckMusicFormat(InPath,InFile);

 { Initialize Output stream }

 OutFile.Init(OutPath, StCreate, 1024);

 { Convert to the specified format }
 Convert(Infile, OutFile, OutType);

 { Close Streams }
 Infile.Done;
 OutFile.Done;
end.
