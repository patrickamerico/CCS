% 
% This MiniZinc model was created by CCS
%

%------------------------------------------------------%

include "globals.mzn";
%%% estudo de matriz adjacencia, INCIDENCIA etc
array[1..n, 1..n] of int : G = [|
    %   1   2   3   
        0,  11, 14 |   % 1
        11, 0,  13 |   % 2
        7,  7,  0  |]; % 6
    

array[1..n, 1..n] of int : TESTE = [|
    %   1   2   3   
        0,  1,  1 |   % 1
        1,  0,  1 |   % 2
        1,  1,  0 |]; % 6
    

% INSTANCIA DO PROBLEMA:
int : n = 3;
int : n_max_arcs = n*n;
var int : custo; %% custo total
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var int : n_arcs;
array[1..n, 1..n] of var 0..1 : MAT_ADJ;
%%% futuro 
%%array[1..n*n, 1..2] of var 0 .. n : INDEX_INCIDENCIA;
%set of int : N_ARCS = 1 .. n_arcs;
array[1..n_max_arcs, 1..2 ] of var 1 .. n : INDEX_INCIDENCIA;
%%function array [int , int] of var 1 .. n
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% grafo de DECISAO que representa o resultado dos nos escolhidos
array[1..n, 1..n] of var 0..1 : x_DECISION;

%%% calcula o numero de ARCOS -- STATUS OK
function var int: num_arcos(array[int,int] of int: Weight_M, int: n) =
   let{
       array [1 .. n*n] of var 0..1 : v_aux;
       var int : temp;
    constraint 
         forall(i , j in 1..n )
         (
          if (Weight_M[i,j] == 0)
          then
           v_aux[j + (i-1)*n] = 0
          else
           v_aux[j + (i-1)*n ] = 1
          endif
         )
         /\
        temp == sum( v_aux ); 
      %% Varias maneiras de fazer a soma acima
         }
          in
      temp 
    %%% OR  directly .... 
  %% somethink as:   sum([v_aux[i] | i in 1..n*n])
         ;

%%% constroi  uma matriz de adjacencia  -- STATUS OK
function array [int,int] of var {0,1}: matriz_adjacencia(array[int,int] of int: Weight_M, int: n) =
   let{
       array[1 .. n, 1 .. n] of var 0..1 : v_aux;
    constraint 
         forall(i,j in 1..n )
         (
          if (Weight_M[i,j] == 0)
          then
           v_aux[i,j] = 0
          else
           v_aux[i,j] = 1
          endif
         )
         }
         in
         v_aux
         ;

%%%%%%%%%%%%%%%%%%%%%%%% novamente 
%%% uma matriz de INDICES para matriz de INCIDENCIA  -- STATUS NAO OK
function array [1..n_max_arcs, 1..2] of var 1 .. n : matriz_index_incidencia
               ( array[int,int] of var 0..1: M_ADJ, int: nodes,  int: n_arcs) =
%%, var int: num_arcos) =

   let{
        var int : i ;
        var int : j ;
        set of int : ONE_TWO = {1,2};
        set of int : N_ARCS = 1 .. n_arcs  ; %% variable to FIX in function
        array[N_ARCS, 1..2] of var 1 .. nodes  : v_aux_0; %%%% incluir o ZERO 1 .. nodes
    constraint 
         %   assert(i, j in index_set_2of2(v_aux_0),
         %          "indices de v_aux_0 fora dos limites", i=0)
         %   /\
/*            v_aux_0[1,1] = 9 /\
            v_aux_0[1,2] = 9 /\
            v_aux_0[n_arcs,1] = 99999 /\
            v_aux_0[n_arcs,2] = 99999 

*/
      forall(i , j  in 1..nodes,  k in N_ARCS) %% num_arcos j in 1..n,
         (
         %   v_aux_0[k,1] = i /\
         %   v_aux_0[k,2] = j 

          if (M_ADJ[i,j] == 1)
          then
           (v_aux_0[k,1] = i /\
            v_aux_0[k,2] = j 
            )
         else
           (v_aux_0[k,1] = 0 /\
            v_aux_0[k,2] = 0 
            )
          endif
        )
         %% DEPOIS eliminar TODOS OS ZEROS  de V_AUX 
       } 
       in
        v_aux_0
      ;


constraint
        n_arcs = num_arcos(G,n);
constraint
        MAT_ADJ = matriz_adjacencia(G,n);
constraint
        INDEX_INCIDENCIA = matriz_index_incidencia( G, n , n_max_arcs );

%%n_max_arcs

%%% EXPLORE HERE
solve satisfy;
%minimize custo;

% Output from Hakank ...OK
% to be improved
output 
 %      [" \n "] ++ [ show(fix(num_arcos(G,n))) ];
       [" \n "] ++ [ show(fix( n_arcs ))] ++[" \n "] ++
[ %%% matriz de adjacencia
  if j == 1 then "\n" else " "  endif ++
       show(MAT_ADJ[i,j]) 
       | i in 1..n, j in 1..n
]
%++[show(matriz_index_incidencia(MAT_ADJ, n, n_max_arcs))]
++[show(INDEX_INCIDENCIA)]
%
%[ %%% matriz de adjacencia
%  if k == 1 then "\n" else " "  endif ++
%       show(fix(INDEX_INCIDENCIA[iz,k])) 
%       | iz in 1..n*n, k in {1,2}
%]
;
