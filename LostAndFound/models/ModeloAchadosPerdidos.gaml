/***
* Name: NewModel
* Author: Matheus
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model NewModel

global {
	
	int nb_pessoa_init <- 10;
	int nb_departamento <- 1;
	int nb_itens_perdidos <- 0;
	int nb_qtdItensOnDep <- 0;
	int nb_qtdItensRecebidos <- 0;
	int nb_qtdItensDevolvidos <- 0;
	int nb_qtdItensRoubados <- 0;
	int nb_pessoas_com_itens_perdidos <- 0;
	int nb_vezes_dep_foi_procurado <- 0;
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
	list<item> itensDep;

	aspect base{
		draw cube(size) color: color;
	}
	
} 
species pessoa skills: [moving]{
	float size <- 1.0 ;
	rgb cor <- #blue;
	bool possuiItem <- true;
	bool CorTeste <- false;
	bool perdeItem <- false;
	bool percebeuPerda <- false;
	item itemProp;//item q a pessao possui
	bool itemAlheio <- false;//mostra se ela possui um item alhieo ou n 
	bool ladrao <- nil;//mostra se ela roubou algum item
	bool foiEmbora <- false;
	bool pedirAjuda <- false;//verificar se a pessoa precisa de ajuda
	bool achouItem <- false;//verifica se a pessoa achou algum item
	bool honestidade <- flip (0.5);// 50¨% de chance de ser true(honesta) e 50% de ser false (desonesta)
	int ciclos <- 0;
	departamento depTarget;//departamento mais proximo;	
	point target <- nil;// point pra localização
	list<item> reachable_item update: item inside (meuEspaco);//cria uma lista com os item proximos de pessoas;
	list<item> itensAlheios;//lista de itens alheios
	
	
	metro meuEspaco <- one_of (metro) ;
	
	//OK!!!
	reflex pegarItem when: !empty(reachable_item) or itemAlheio{// verifica se tem o item na msm localização q ele;
		if (perdeItem = false){//verifica se ele acabou de perder o item 	
			ask one_of (reachable_item){//escolhe o item q achou
				//add item achado a lista de itensalheio q a pessoa possui;
				add self to:myself.itensAlheios;
				do die;//'mata' o item na forma de dizer q a pessoa o pegou;
			}
			
			 if(itensAlheios contains (itemProp)){//verifica se na lista de itens alheios daquela pessoa estar o item que ela perdeu
				achouItem <- true;
				possuiItem <- true;
				//retira os item que já era da pessoa da lista de itens alheios,
				//considera a possibilidade de existir mais de uma instacia do msm item.
				remove all: itemProp from: itensAlheios;
				nb_qtdItensDevolvidos <- nb_qtdItensDevolvidos + 1;//add a global de itens devolvidos
				target <- nil;//zera o target, caso ela já estivesse indo ao atendimento 
				
				
			}else if(honestidade){//verifica se é honesto				
				itemAlheio <- true;//verifica se a pessoa tem item alheio
				
				ask departamento {//procura o departamento mais proximo;
					myself.target <- self;
				}
					
				do goto target: target;
				if(target = location){	
							ask departamento{//transfere o item para o departamento
								loop i from: 0 to:length(myself.itensAlheios) -1{//transfere itens q a pessoa achou para item do departamento
									add myself.itensAlheios[i] to:self.itensDep;
								}				
								nb_qtdItensOnDep <- length(self.itensDep);//atualiza o contador quantos itens o departamento possui
								nb_qtdItensRecebidos <- nb_qtdItensRecebidos + 1;
								myself.itemAlheio <- false;
								myself.itensAlheios<-nil;//zera a lista de itens alhies daquela pessao;
								myself.target <- nil;//zera o target								
							}	
				}		
			}else{//se n for honesto
				ladrao <- true;
				nb_qtdItensRoubados <- nb_qtdItensRoubados + 1;
				}
		}
		else if (perdeItem){//a pessao q acabou de perder o item agora pode "procurar" e pegar o item perdido;
			perdeItem <- false;
			}	
	}
	//OK!!
	reflex procuraAjuda when: pedirAjuda{
		//Vai até uma estação de comunicação
		ask departamento {//procura o departamento mais proximo;
					myself.target <- self;
				}
		do goto target:target ;
		if(target = location){			
			ask departamento{// para acessar a lista do departamento						
						if (self.itensDep contains (myself.itemProp)){//verifica se o item q a pessoa perdeu está no departamento
							remove all: myself.itemProp from:self.itensDep;//caso a pessoa encontre o item o msm será removido do itensDep
							myself.possuiItem <- true;//a pessoa volta a possui o item
							nb_qtdItensDevolvidos <- nb_qtdItensDevolvidos + 1;//add a global de itens devolvidos											
					}
				myself.target <- nil;
				myself.pedirAjuda <-false;
				myself.percebeuPerda<-false;
			}
		}		
	}
	//OK!!!!
	reflex movimentacaoBasica when: target = nil and not pedirAjuda{ 
		//Movimenta duas casa a cada ciclo
		meuEspaco <- one_of (meuEspaco.vizinhos) ;
		location <- meuEspaco.location ;
		//Conta os ciclos
		ciclos <- ciclos + 1;
		//Se pessoa não possui o item e ainda não percebeu perda
		if(possuiItem = false  and  percebeuPerda = false){
		//1% de chance de perceber	
			percebeuPerda <- flip (0.01);
				if percebeuPerda {
					pedirAjuda <- true; 
					nb_vezes_dep_foi_procurado <- nb_vezes_dep_foi_procurado + 1;
				}	
		}
	}	
	//OK!!!!
	//Pode perder o item somente quando possuir	
	reflex perde when: possuiItem {
		//1% de chance de perder o item
		perdeItem <- flip (0.01);
		//Se perder o item, cria uma novo no ambiente
		if (perdeItem){			
			possuiItem <-false;
			nb_cogidoItem <- nb_cogidoItem + 1;//atualiza a varialvel global
			create item{//cria o item quando a pessoa perde o msm;
				meuEspaco <- myself.meuEspaco;//define o local o item será "perdido"/"deixado";
				location <- meuEspaco.location;	//passa os parametros da localização;
				codigo <- nb_cogidoItem;//atualizad codigo do item;
				myself.itemProp <- self;//item q perdeu mo item da pessoa
			}
			//Acrescenta o número de itens na variavel global
			nb_itens_perdidos <- nb_itens_perdidos + 1;	
			nb_pessoas_com_itens_perdidos <- nb_pessoas_com_itens_perdidos + 1;
		}	
	}	
	//OK!!!!
	//Após 100 ciclos mínimos a pessoa pode ir embora
	reflex irEmbora when: ciclos > 100 and not pedirAjuda{
		foiEmbora <- flip (0.003);
		if foiEmbora{
			nb_pessoa_init <- nb_pessoa_init - 1;
			do die;	
		}			
	}
	
	
	//Legenda de cores: 
	//Azul - Possui o item
	//Verde - Perdeu o item
	//Amarelo - Percebeu que perdeu o item	
	//Laranja - Recupera o proprio item que perde
	//Vermelho - Roubou algum item	
	aspect base {
		if (possuiItem){
			cor <- #blue;
		}
		else if(percebeuPerda){
			cor <- #yellow;
		}		
		else{
			cor <- #green;
		}
		if(achouItem and possuiItem){
			cor <- #orange;	
		}
		if (ladrao){
			cor <- #red;
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
      	//novoUsuario <- flip (0.00005); //Cria novas pessoas aleatoriamente
      	if novoUsuario {
      		create pessoa;
      		nb_pessoa_init <- nb_pessoa_init + 1;
      	}
      }
   }

experiment AchadosPerdidos type: gui {
	parameter "Número de pessoas iniciais: " var: nb_pessoa_init  category: "Pessoa" ;
	parameter "Número de itens perdidos: " var: nb_itens_perdidos category: "Itens" ;
	parameter "Número de itens recebido: " var: nb_qtdItensOnDep category: "departamento";
	parameter "Número de itens devolvidos: " var: nb_qtdItensDevolvidos category: "departamento";
	parameter "Nº de vezes que o depart. foi procurado: " var: nb_vezes_dep_foi_procurado category: "departamento";
	output {
		display main_display {
			grid metro lines: #black ;
			species pessoa aspect: base ;
			species item aspect: base ;
			species departamento aspect: base ;
		}
		monitor "Nº de pessoas no metrô" value: nb_pessoa_init;
		monitor "Nº de itens perdidos" value: nb_itens_perdidos;
		monitor "Nº de pessoas que perderam itens" value: nb_pessoas_com_itens_perdidos;		
		monitor "Nº de pessoas que recuperaram itens" value: nb_qtdItensDevolvidos;
		monitor "Nº de vezes que o depart. foi procurado" value: nb_vezes_dep_foi_procurado; 
		monitor "Nº de itens que o departamento possui" value: nb_qtdItensOnDep;
		monitor "Nº de itens que o departamento recebeu" value: nb_qtdItensRecebidos;		 
		monitor "Nº de itens roubados" value: nb_qtdItensRoubados;
	}
}