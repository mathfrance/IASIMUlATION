/***
* Name: NewModel
* Author: Matheus
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model NewModel

global {
	int nb_pessoa_init <- 50;
	int nb_itens_perdidos <- 0;
	int nb_pessoas_com_itens_perdidos <- 0;
	int nb_pessoas_que_perceberam_que_perderam <- 0;
	init {
		create pessoa number: nb_pessoa_init ;
	}
}

species pessoa {
	float size <- 1.0 ;
	rgb cor <- #blue;
	bool possuiItem <- true;
	bool perdeItem <- false;
	bool percebeuPerda <- false;
	int ciclos <- 0;		
	metro meuEspaco <- one_of (metro) ;
	
	init {
		location <- meuEspaco.location;
	}
	
	reflex movimentacaoBasica { 
		//Movimenta duas casa a cada ciclo
		meuEspaco <- one_of (meuEspaco.vizinhos) ;
		location <- meuEspaco.location ;
		//Conta os ciclos
		ciclos <- ciclos + 1;
		//Se pessoa não possui o item e ainda não percebeu perda
		if not(possuiItem) and not(percebeuPerda){
		//5% de chance de perceber
			percebeuPerda <- flip (0.05);
			if percebeuPerda {
				nb_pessoas_que_perceberam_que_perderam <- nb_pessoas_que_perceberam_que_perderam + 1;
			}		
		}
	}
	
	//Pode perder o item somente quando possuir	
	reflex perde when: possuiItem{
		//1% de chance de perder o item
		perdeItem <- flip (0.01);
		//Se perder o item, cria uma novo no ambiente
		if (perdeItem){			
			possuiItem <-false;
			create item;
			//Acrescenta o número de itens na variavel global
			nb_itens_perdidos <- nb_itens_perdidos + 1;	
			nb_pessoas_com_itens_perdidos <- nb_pessoas_com_itens_perdidos + 1;
		}	
	}
	
	reflex procuraAjuda when: percebeuPerda{
		//Vai até uma estação de comunicação
	}
	//Após 500 ciclos a pessoa vai embora
	reflex irEmbora when: ciclos > 500{
		nb_pessoa_init <- nb_pessoa_init - 1;
		do die;			
	}
	
	//Legenda de cores: 
	//Azul - Possui o item
	//Verde - Perdeu o item
	//Amarelo - Percebeu que perdeu o item		
	aspect base {
		if (possuiItem){
			cor <- #blue;
		}
		else if(percebeuPerda){
			cor <- #yellow;
		}
		else {
			cor <- #green;
		}
		draw circle(size) color:cor;		
	}
} 

species item {
	float size <- 0.8 ;
	rgb color <- #black;
	
		
	aspect base {
		draw square(size) color: color ;
	}
} 

//Ambiente do metrô criado
grid metro width: 50 height: 50 neighbors: 4 {
      list<metro> vizinhos  <- (self neighbors_at 2);
   }

experiment AchadosPerdidos type: gui {
	parameter "Número de pessoas iniciais: " var: nb_pessoa_init  category: "Pessoa" ;
	parameter "Número de itens perdidos: " var: nb_itens_perdidos category: "Itens" ;
	output {
		display main_display {
			grid metro lines: #black ;
			species pessoa aspect: base ;
			species item aspect: base ;
		}
		monitor "Número de pessoas no metrô" value: nb_pessoa_init;
		monitor "Número de itens perdidos" value: nb_itens_perdidos;
		monitor "Nº de pessoas que perderam itens" value: nb_pessoas_com_itens_perdidos;
		monitor "Nº de pessoas que percebeu perda" value: nb_pessoas_que_perceberam_que_perderam;
	}
}

