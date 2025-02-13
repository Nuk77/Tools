#!/usr/bin/python3
import sys

print("Bem-vindo a Calculadora RAWR JAVARDONA!!!")


def somar(numero1, numero2):
        return numero1 + numero2

def dividir(numero1, numero2):
	try:
		resultado = numero1 / numero2
	except ZeroDivisionError:
		resultado = "PUTA DE BURRO RAWR!! Queres dividir por zero cao sujo do crl?"

	return resultado



if len(sys.argv) >= 3:
	if sys.argv[1].isdigit() and sys.argv[2].isdigit():
		primeiro_numero = int(sys.argv[1])
		segundo_numero = int(sys.argv[2])

		print("O crl da soma eh:", somar(primeiro_numero, segundo_numero))
		print("A conice da divisao eh:", dividir(primeiro_numero, segundo_numero))
	else: print("OHH CRL 2 numeros FDP RAWR!!")
else:
	print("A porca da tua irma em cima aqui do DinoRawr.. Tens de passar 2 numeros")
	print("")
