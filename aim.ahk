﻿#Persistent
#KeyHistory, 0
#NoEnv
#HotKeyInterval 1
#MaxHotkeysPerInterval 127
#InstallKeybdHook
#UseHook
#SingleInstance, Force
#include Lib\AutoHotInterception.ahk
global AHI := new AutoHotInterception()
#NoTrayIcon

; Caminho do arquivo config.ini
configFilePath := "C:\Windows\PLA\System\config.ini"

; Função para carregar a configuração do arquivo
LoadConfig() {
    global Smooth, CfovX, CfovY, ColVn, ScreenWidth, ScreenHeight, configFilePath
    CreateConfigFile()  ; Garante que o arquivo existe

    ; Carrega os valores das configurações
    IniRead, Smooth, %configFilePath%, Settings, Smooth, 0.0
    IniRead, CfovX, %configFilePath%, Settings, CfovX, 0
    IniRead, CfovY, %configFilePath%, Settings, CfovY, 0
    IniRead, ColVn, %configFilePath%, Settings, ColVn, 0
    IniRead, ScreenWidth, %configFilePath%, Settings, ScreenWidth, %A_ScreenWidth%
    IniRead, ScreenHeight, %configFilePath%, Settings, ScreenHeight, %A_ScreenHeight%
}

; Garante que o arquivo config.ini exista
CreateConfigFile() {
    global configFilePath
    if !FileExist(configFilePath) {
        FileAppend, [Settings]nSmooth=0.0nCfovX=0nCfovY=0nColVn=0nScreenWidth=%A_ScreenWidth%nScreenHeight=%A_ScreenHeight%n, %configFilePath%
    }
}

; Carrega as configurações no início do script
LoadConfig()

EMCol := "0xd721cd"

SetKeyDelay, -1, 8
SetControlDelay, -1
SetMouseDelay, -1
SetWinDelay, -1
SendMode, InputThenPlay
SetBatchLines, -1
ListLines, Off
CoordMode, Pixel, Screen, RGB
CoordMode, Mouse, Screen
PID := DllCall("GetCurrentProcessId")
Process, Priority, %PID%, High
AimBotON := true

; Parâmetros de configuração
ZeroX := ScreenWidth // 2
ZeroY := ScreenHeight // 2
ScanL := ZeroX - CfovX
ScanT := ZeroY - CfovY
ScanR := ZeroX + CfovX
ScanB := ZeroY + CfovY
IngameSensitivity := 10
BustSpeed := 0.05


Loop
{
    ; Ativa a busca quando o botão direito do mouse é pressionado
    if GetKeyState("RButton", "P") {
        if AimBotON {
            ; Define a área de busca
            ScanL := ZeroX - CfovX
            ScanR := ZeroX + CfovX
            ScanT := ZeroY - CfovY
            ScanB := ZeroY + CfovY

            PixelSearch, AimPixelX, AimPixelY, ScanL, ScanT, ScanR, ScanB, EMCol, ColVn, Fast RGB

            if (ErrorLevel = 0) { ; Se a cor for encontrada
                GoSub GetAimOffset
                GoSub GetAimMoves
                GoSub MouseMoves
            }
        }
    }
    else {
        ; Reseta o estado quando o botão direito não está pressionado
        AimPixelX := ""
        AimPixelY := ""
    }
    Sleep, 10  ; Reduz uso de CPU no loop
}

GetAimOffset:
    AimX := AimPixelX - ZeroX
    AimY := AimPixelY - ZeroY
    DirX := (AimX > 0) ? 1 : -1
    ; Ajusta a AimOffsetY para "puxar" a mira para o peito
    AimOffsetX := AimX * DirX
    AimOffsetY := 0
Return

GetAimMoves:
    RootX := Ceil((AimOffsetX ** 1))
    MoveX := (RootX * DirX) / Smooth
    MoveY := 0 ; Não há movimento em Y
Return

MouseMoves:
    MoveMultipler := ((0.0066 * IngameSensitivity * 1) / BustSpeed)
    AHI.SendMouseMove(11, MoveX * MoveMultipler, MoveY * MoveMultipler)
    AHI.SendMouseMove(12, MoveX * MoveMultipler, MoveY * MoveMultipler)
    AHI.SendMouseMove(13, MoveX * MoveMultipler, MoveY * MoveMultipler)
Return

GuiClose:
ExitApp