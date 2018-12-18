/***
* Name: NewModel
* Author: Matheus
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model NewModel

global {
	int nb_pessoa_init <- 50;
	int nb_departamento <- 1;
	int nb_itens_perdidos <- 0;
	int nb_qtdItensRecebidos <- 0;
	int nb_qtdItensDevolvidos <- 0;
	int nb_pessoas_com_itens_perdidos <- 0;
	int nb_pessoas_que_perceberam_que_perderam <- 0;
	int nb_cogidoItem <- 0;
	init {
		create pessoa number: nb_pessoa_init ;
		create departamento number: nb_departamento ;
	}
}

species departamento{
	float size <- 5.0 ;
	rgb color <- #purple;
	metro meuEspaco <- one_of (metro);//coloca o departamento dentro do metro;
	int qtdItensRecebidos;
	int qtdItensDevolvidos;
	point target <- meuEspaco.location; 

	
	init{
		location <- meuEspaco.location;
		
	}
	
	aspect base{
		draw cube(size) color: color;
	}
	
} 
species pessoa skills: [moving]{
	float size <- 1.0 ;
	rgb cor <- #blue;
	bool possuiItem <- true;
	bool perdeItem <- false;
	bool percebeuPerda <- false;
	bool itemAlheio <- false ;
	bool ladrao <- false;
	bool foiEmbora <- false;
	bool pedirAjuda <- false;
	int ciclos <- 0;
	int numItem <- 0;//numero do item q o usuario perdeu
	departamento depTarget <-nil;
	point target <- nil;	
	list<item> reachable_item update: item inside (meuEspaco);//cria uma lista com os item proximos de pessoas;
	list<item> itensAlheios;
	
	metro meuEspaco <- one_of (metro) ;
	
	init {
		location <- meuEspaco.location;
	}
	
	reflex movimentacaoBasica when:target = nil{ 
		//Movimenta duas casa a cada ciclo
		meuEspaco <- one_of (meuEspaco.vizinhos) ;
		location <- meuEspaco.location ;
		//Conta os ciclos
		ciclos <- ciclos + 1;
		//Se pessoa não possui o item e ainda não percebeu perda
	
	}
	reflex perceberPerda when: possuiItem = false  and  percebeuPerda = false{
		//1% de chance de perceber
			percebeuPerda <- flip (0.01);
			if percebeuPerda {
				pedirAjuda <- true;
				 target <- depTarget.target; 
				nb_pessoas_que_perceberam_que_perderam <- nb_pessoas_que_perceberam_que_perderam + 1;
			}		
		
	}
	//Pode perder o item somente quando possuir	
	reflex perde when: possuiItem {
		//1% de chance de perder o item
		perdeItem <- flip (0.01);
		//Se perder o item, cria uma novo no ambiente
		if (perdeItem){			
			possuiItem <-false;
			nb_cogidoItem <- nb_cogidoItem + 1;//atualiza a varialvel global
			numItem <- nb_cogidoItem;//atualiza o item q o usuario perdeu
			create item{//cria o item quando a pessoa perde o msm;
				meuEspaco <- myself.meuEspaco;//define o local o item será "perdido"/"deixado";
				location <- meuEspaco.location;	//passa os parametros da localização;
				codigo <- nb_cogidoItem;//atualizad codigo do item;
				
			}
			//Acrescenta o número de itens na variavel global
			nb_itens_perdidos <- nb_itens_perdidos + 1;	
			nb_pessoas_com_itens_perdidos <- nb_pessoas_com_itens_perdidos + 1;
		}	
	}
	
	reflex procuraAjuda when: pedirAjuda {
		//Vai até uma estação de comunicação
		do goto target: target;
		if (target = location){
			color <- #grey;
			pedirAjuda <-false;
		}
	}
	//Após 100 ciclos mínimos a pessoa pode ir embora
	reflex irEmbora when: ciclos > 100{
		foiEmbora <- flip (0.003);
		if foiEmbora{
			nb_pessoa_init <- nb_pessoa_init - 1;
			do die;	
		}			
	}
	reflex pegarItem when: !empty(reachable_item){// verifica se tem o item na msm localização q ele;
		if (perdeItem = false){//verifica se ele acabou de perder o item 
			ask one_of (reachable_item){//escolhe o item q achou
				do die;//'mata' o item na forma de dizer q a pessoa o pegou;
			}
			itemAlheio <- true;//a pessoa pegou um item q n é dela;
		}
		else if (perdeItem){//a pessao q acabou de perder o item agora pode "procurar" e pegar o item perdido;
				perdeItem <- false;
			}
		
		
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
	int codigo <- 0;
	metro meuEspaco <- one_of (metro) ;//coloca o objeto dentro do metro;
	
	init {
		location <- meuEspaco.location;//inicia com a posição;
	}
		
	aspect base {
		draw square(size) color: color ;
	}
}


//Ambiente do metrô criado
grid metro width: 50 height: 50 neighbors: 4 {
      list<metro> vizinhos  <- (self neighbors_at 2);
      bool novoUsuario <- false;
      
      reflex recebePessoas{
      	novoUsuario <- flip (0.00005);
      	if novoUsuario {
      		create pessoa;
      		nb_pessoa_init <- nb_pessoa_init + 1;
      	}
      }
   }

experiment AchadosPerdidos type: gui {
	parameter "Número de pessoas iniciais: " var: nb_pessoa_init  category: "Pessoa" ;
	parameter "Número de itens perdidos: " var: nb_itens_perdidos category: "Itens" ;
	parameter "Número de itens recebido: " var: nb_qtdItensRecebidos category: "departamento";
	parameter "Número de itens devolvidos: " var: nb_qtdItensDevolvidos category: "departamento";
	output {
		display main_display {
			grid metro lines: #black ;
			species pessoa aspect: base ;
			species item aspect: base ;
			species departamento aspect: base ;
		}
		monitor "Número de pessoas no metrô" value: nb_pessoa_init;
		monitor "Número de itens perdidos" value: nb_itens_perdidos;
		monitor "Nº de pessoas que perderam itens" value: nb_pessoas_com_itens_perdidos;
		monitor "Nº de pessoas que percebeu perda" value: nb_pessoas_que_perceberam_que_perderam;
		monitor "Nº de pessoas que recuperaram itens" value: nb_qtdItensDevolvidos;
		monitor "Nº de itens que o departamento recebeu" value: nb_qtdItensRecebidos;
	}
}