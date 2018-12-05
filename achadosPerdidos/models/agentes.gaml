/***
* Name: agentes
* Author: Rog�rioAmorim
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model agentes

/* Insert your model definition here */

/*INICIA AS VARIAVEIS GLOBAIS, ONDE DEFINE QUANTIDADE DE AGENTES QUE SERÃO USADAS NA SIMULAÇÃO

*/
global{
	int nbPessoasInit  <- 12;
	bool pessoaObjeto <- true;
	float pessoaHonestidade <- (rnd(1000) / 1000) * 0.01;
	float pessoaDesonestidade <- (rnd(1000) / 1000) * 0.01;
	init {
		create pessoas number: nbPessoasInit;
	}
}
/*CRIA UMA ESPECIE PESSOAS, TIPO DE AGENTE, COM SEUS PARAMETROS E FUNÇÕES*/ 
species pessoas {
	float size <- 1.0;
	rgb color <- #blue;
	bool objeto <- pessoaObjeto;
	float honestidade <- pessoaHonestidade;
	float desonestidade <- pessoaDesonestidade;
	
	metro myCell <- one_of (metro);
	
	init{
		location <-myCell.location;
	}
	reflex mover{
	   myCell <- one_of (myCell.neighbours) ;
       location <- myCell.location ;
	}
	aspect base{
		draw circle(size) color: color;	
	}
	
}

grid metro width:50 height:50 neighbours: 4 {
	bool  maxObjeto <- false;
	rgb color <- (maxObjeto = false) ? #black : #red; 
	list<metro> neighbours <- self neighbours_at 2;//lista para manter a distancia dos agentes em 2x2
}

/*INICIALIZA A SIMULAÇÃO, DEFININDO O TIPO(COM OU SEM INTERFACE GRAFICA: GUI), 
OS PARAMENTROS(INPUT) E A SAIDA(OUPUT) PARA VISUALIZAÇÃO DO PROJETO*/
experiment pessoasCirculando type: gui{
	parameter "Initial numbers of pessoas: " var: nbPessoasInit min:1 max:100 category: "Pessoas";
	parameter "Pessoa's object: " var: pessoaObjeto category: "Pessoas";
	parameter "Pessoa's honesty: " var: pessoaHonestidade category: "Pessoas";
	parameter "Pessoa's inhonesty: " var: pessoaDesonestidade category: "Pessoas";
	
	
	output{
		display main_display{
			grid metro lines: #yellow;
			species pessoas aspect: base;
			
		}
	}
}
