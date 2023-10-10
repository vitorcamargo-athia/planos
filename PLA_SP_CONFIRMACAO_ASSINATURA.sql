CREATE OR REPLACE PROCEDURE 
       PLA_SP_CONFIRMACAO_ASSINATURA(V_COD_CONTRATO NUMBER,
                                     V_NOVA_DATA_VENDA DATE,
                                     V_NOVA_DATA_CARENCIA DATE,
                                     V_NOVO_PRIM_VENCTO DATE,
                                     
                                     V_COD_USUARIO_LOGADO NUMBER,
                                     V_OPERACAO VARCHAR DEFAULT 'ASS') IS
       
  V_QTD NUMBER(20) :=0;
  V_QTD_FALEC NUMBER(20) :=0;
  V_DATA_VENDA_ATUAL DATE;
  V_CARENCIA_ATUAL DATE;
  V_PRIMEIRO_VENCTO_ATUAL DATE;
  V_DATA_ATIVACAO DATE;
  V_MIGRACAO VARCHAR2(3);
  V_CARENCIA_SAF VARCHAR2(5);
  V_QTD_MUDANCA_MES NUMBER(20) :=0;
  V_COD_PARCELA NUMBER(20);
  V_NRO_CONTRATO NUMBER(20);
  V_COD_GRUPO_VENDA NUMBER(20);
  V_ERRO_TMP VARCHAR2(4000);
  V_TIPO_PLANO NUMBER(20);

  CURSOR CUR_CONTRATO IS
    SELECT C.N_NRO_CONTRATO, C.D_DATA_VENDA, C.D_CARENCIA, C.D_PRIMEIRO_VENCTO, C.D_ATIVACAO, 
           DECODE(NVL(C.N_NRO_CONTRATO_ANTERIOR,0),0,'NÃO','SIM'), V.N_COD_GRUPO_VENDA,
           C.N_COD_TIPO_PLANO
      FROM PLA_CONTRATO C
            LEFT JOIN PLA_VENDEDOR V ON (V.N_COD_VENDEDOR = C.N_COD_VENDEDOR)
     WHERE C.N_COD_CONTRATO = V_COD_CONTRATO;
  
BEGIN
  
  SELECT COUNT(1) INTO V_QTD
    FROM GER_USUARIO_X_GRUPO_ACESSO
   WHERE (V_COD_USUARIO_LOGADO IN (2,408,436,117) OR N_COD_USUARIO = V_COD_USUARIO_LOGADO)
     AND N_COD_GRUPO_ACESSO IN (1,36,40);

  OPEN CUR_CONTRATO;
  FETCH CUR_CONTRATO INTO V_NRO_CONTRATO, V_DATA_VENDA_ATUAL, V_CARENCIA_ATUAL, 
                          V_PRIMEIRO_VENCTO_ATUAL, V_DATA_ATIVACAO, V_MIGRACAO,
                          V_COD_GRUPO_VENDA, V_TIPO_PLANO;

  IF CUR_CONTRATO%FOUND THEN
    
    IF V_TIPO_PLANO IN (8,9,10,11) THEN 
      ROLLBACK;  
      INSERT INTO ATHIA.G_ENVIO_EMAIL T
       (T.C_ASSUNTO, T.C_EMAIL_DESTINO, T.C_EMAIL_ORIGEM, T.C_MENSAGEM)
      VALUES ('CONTRATO NAO COMERCIALIZADO - PLA_SP_CONFIRMACAO_ASSINATURA','desenvolvimento@athia.com.br',
          'desenvolvimento@athia.com.br','N_COD_CONTRATO '|| V_COD_CONTRATO ||
          '<br>Contrato '|| V_NRO_CONTRATO ||
          '<br>Venda De '|| V_DATA_VENDA_ATUAL ||' para '|| V_NOVA_DATA_VENDA || 
          '<br>Carencia De '|| V_CARENCIA_ATUAL ||' para '|| V_NOVA_DATA_CARENCIA ||
          '<br>Primeiro Vencto De '|| V_PRIMEIRO_VENCTO_ATUAL ||' para '|| V_NOVO_PRIM_VENCTO);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20001,'ESTE TIPO DE PLAN NAO E MAIS COMERCIALIZADO !');
    END IF;
    
    SELECT COUNT(1) INTO V_QTD_FALEC
      FROM PLA_CONTRATO C1
             INNER JOIN PLA_CONTRATO C2
              ON (PLA_FN_TITULAR_CONTRATO(C2.N_COD_CONTRATO,'DF') IS NOT NULL
                  AND C2.N_NRO_CONTRATO = C1.N_NRO_CONTRATO_ANTERIOR)
     WHERE C1.N_COD_CONTRATO = V_COD_CONTRATO;
       
    SELECT DECODE(COUNT(1),0,'S','N') INTO V_CARENCIA_SAF 
      FROM PLA_OCORRENCIAS
     WHERE N_COD_TIPO_OCOR = 285 AND N_COD_CONTRATO = V_COD_CONTRATO;
     
    IF TO_CHAR(V_PRIMEIRO_VENCTO_ATUAL,'DD') <> TO_CHAR(V_NOVO_PRIM_VENCTO,'DD') THEN
       --ALTERA SOMENTE O PRIMEIRO VENCIMENTO
       UPDATE PLA_CONTRATO
          SET D_PRIMEIRO_VENCTO = V_NOVO_PRIM_VENCTO,
              N_COD_USUARIO_LOGADO = V_COD_USUARIO_LOGADO
        WHERE N_COD_CONTRATO = V_COD_CONTRATO;
        
      FOR X IN (SELECT P.N_COD_PARCELA,
                       (CASE
                         WHEN TRIM(TO_CHAR(P.D_DATA_VENCTO,'MM')) = '02' AND C.N_DIA_VECTO_PARCELA IN (29,30,31)
                          THEN TRIM('28' || TO_CHAR(P.D_DATA_VENCTO,'MMRRRR'))
                         ELSE TRIM(C.N_DIA_VECTO_PARCELA || TO_CHAR(P.D_DATA_VENCTO,'MMRRRR')) END) AS D_DATA_VENCTO
                  FROM PLA_PARCELAS P
                         INNER JOIN PLA_CONTRATO C ON (C.N_COD_CONTRATO = P.N_COD_CONTRATO)
                 WHERE P.N_NUM_PARCELA > 0
                   AND P.D_CANCELAMENTO IS NULL
                   AND P.N_COD_CONTRATO = V_COD_CONTRATO
                 ORDER BY P.D_DATA_VENCTO) LOOP
                                           
         UPDATE PLA_PARCELAS
            SET D_DATA_VENCTO = TO_DATE(X.D_DATA_VENCTO,'DDMMRRRR')
          WHERE N_COD_PARCELA = X.N_COD_PARCELA;
                    
      END LOOP;
    END IF;
      
    IF V_DATA_VENDA_ATUAL <> V_NOVA_DATA_VENDA AND V_CARENCIA_ATUAL <> V_NOVA_DATA_CARENCIA THEN

       UPDATE PLA_CONTRATO
          SET D_DATA_VENDA = V_NOVA_DATA_VENDA, 
              D_CARENCIA = V_NOVA_DATA_CARENCIA,
              D_PRIMEIRO_VENCTO = V_NOVO_PRIM_VENCTO,
              N_COD_USUARIO_LOGADO = V_COD_USUARIO_LOGADO
        WHERE N_COD_CONTRATO = V_COD_CONTRATO;

       UPDATE PLA_CONTRATO_PESSOA
          SET D_CARENCIA = V_NOVA_DATA_CARENCIA
        WHERE D_CARENCIA = V_CARENCIA_ATUAL
          AND N_COD_CONTRATO = V_COD_CONTRATO;

       IF V_CARENCIA_SAF = 'C' THEN
          UPDATE PLA_SERVICOS_AUTORIZADOS
             SET D_INICIAL = V_NOVA_DATA_CARENCIA
           WHERE D_INICIAL = V_CARENCIA_ATUAL
             AND N_COD_CONTRATO = V_COD_CONTRATO;
       ELSE
          UPDATE PLA_SERVICOS_AUTORIZADOS
             SET D_INICIAL = V_NOVA_DATA_CARENCIA
           WHERE N_COD_TIPO_SERVICO = 1
             AND N_COD_CONTRATO = V_COD_CONTRATO;
               
          UPDATE PLA_SERVICOS_AUTORIZADOS
             SET D_INICIAL = V_NOVA_DATA_CARENCIA
           WHERE N_COD_TIPO_SERVICO <> 1
             AND D_INICIAL = V_CARENCIA_ATUAL
             AND N_COD_CONTRATO = V_COD_CONTRATO;
       END IF;
         
       IF V_OPERACAO = 'ADT' OR V_OPERACAO = 'ASS' THEN
          SELECT TRUNC(MONTHS_BETWEEN (TRUNC(V_NOVA_DATA_VENDA,'MM'), 
                                       TRUNC(V_DATA_VENDA_ATUAL,'MM')),0)
            INTO V_QTD_MUDANCA_MES
            FROM DUAL;
              
          UPDATE PLA_PARCELAS
             SET D_DATA_VENCTO = V_NOVA_DATA_VENDA
           WHERE N_NUM_PARCELA = 0
             AND D_DATA_VENCTO <> V_NOVA_DATA_VENDA
             AND N_COD_CONTRATO = V_COD_CONTRATO;
              
          IF V_QTD_MUDANCA_MES > 0 THEN
            FOR X IN (SELECT P.N_COD_PARCELA, P.N_NUM_PARCELA, P.D_DATA_VENCTO, 
                             (CASE
                                WHEN TO_CHAR(ADD_MONTHS(P.D_DATA_VENCTO,1),'DD') = 31 
                                  THEN TRIM(TO_CHAR((ADD_MONTHS(P.D_DATA_VENCTO,1)-1),'DDMMRRRR'))
                                  ELSE TRIM(TO_CHAR(ADD_MONTHS(P.D_DATA_VENCTO,1),'DDMMRRRR')) END) AS D_DATA_VENCTO_NOVO,
                             TRIM(TO_CHAR(P.D_DATA_VENCTO,'MM')) AS MES_VENCTO
                        FROM PLA_PARCELAS P
                       WHERE P.N_NUM_PARCELA > 0
                         AND P.D_CANCELAMENTO IS NULL
                         AND P.N_COD_CONTRATO = V_COD_CONTRATO
                       ORDER BY P.D_DATA_VENCTO) LOOP
                                     
               V_COD_PARCELA := X.N_COD_PARCELA;
               UPDATE PLA_PARCELAS
                  SET D_DATA_VENCTO = TO_DATE(X.D_DATA_VENCTO_NOVO,'DDMMRRRR')
                WHERE N_COD_PARCELA = V_COD_PARCELA;
              
            END LOOP;
              
            UPDATE PLA_PARCELAS
               SET N_NUM_PARCELA = (N_NUM_PARCELA-1), 
                   D_CANCELAMENTO = SYSDATE, N_COD_MOTIVO = 2
             WHERE N_COD_PARCELA = V_COD_PARCELA;
                 
          END IF;
            
          IF V_QTD_MUDANCA_MES < 0 THEN
            INSERT INTO ATHIA.G_ENVIO_EMAIL T
             (T.C_ASSUNTO, T.C_EMAIL_DESTINO, T.C_EMAIL_ORIGEM, T.C_MENSAGEM)
            VALUES ('ALTERACAO DE DATA DE VENDA PARA MES ANTERIOR',
                    'desenvolvimento@athia.com.br',
                    'desenvolvimento@athia.com.br',
                    'N_COD_CONTRATO '|| V_COD_CONTRATO ||
                    '<br>Contrato '|| V_NRO_CONTRATO ||
                    '<br>Venda De '|| V_DATA_VENDA_ATUAL ||' para '|| V_NOVA_DATA_VENDA || 
                    '<br>Carencia De '|| V_CARENCIA_ATUAL ||' para '|| V_NOVA_DATA_CARENCIA ||
                    '<br>Primeiro Vencto De '|| V_PRIMEIRO_VENCTO_ATUAL ||' para '|| V_NOVO_PRIM_VENCTO);
          END IF;
           
       END IF;
    END IF;
      
   UPDATE PLA_SERVICOS_AUTORIZADOS
      SET D_INCLUSAO = V_NOVA_DATA_VENDA
    WHERE N_COD_TIPO_SERVICO IN (23,25,26) AND D_FINAL IS NULL
      AND N_COD_CONTRATO = V_COD_CONTRATO;
            
   IF V_OPERACAO = 'ASS' AND V_QTD > 0 THEN
     --RAISE_APPLICATION_ERROR(-20001, 'TESTE TI');
     IF V_MIGRACAO = 'SIM' AND V_DATA_ATIVACAO IS NULL THEN
        UPDATE PLA_CONTRATO
           SET D_ATIVACAO = SYSDATE,
               N_COD_USUARIO_LOGADO = V_COD_USUARIO_LOGADO
         WHERE N_COD_CONTRATO = V_COD_CONTRATO;
               
        INSERT INTO PLA_STATUS_X_CONTRATO
           (N_COD_STATUS, N_COD_CONTRATO, N_COD_USUARIO_LOGADO, D_INICIO, N_COD_STATUS_MOTIVO)
        VALUES (5, V_COD_CONTRATO, V_COD_USUARIO_LOGADO, SYSDATE, 21);
     END IF;

     FOR X IN (SELECT CP.N_COD_CONTRATO
                 FROM PLA_CONTRATO_PESSOA CP
                       INNER JOIN PLA_CONTRATO C
                        ON (C.D_DATA_CANCELAMENTO IS NULL
                            AND C.N_COD_CONTRATO = CP.N_COD_CONTRATO)
                WHERE CP.N_COD_GRAU_PARENTESCO = 1
                  AND CP.N_COD_CONTRATO <> V_COD_CONTRATO
                  AND CP.D_CANCELAMENTO IS NULL
                  AND CP.N_COD_PESSOA = PLA_FN_TITULAR_CONTRATO(V_COD_CONTRATO,'CD')
                  AND ROWNUM <= 10) LOOP
        INSERT INTO PLA_STATUS_X_CONTRATO
           (N_COD_STATUS, N_COD_CONTRATO, N_COD_USUARIO_LOGADO, D_INICIO, N_COD_STATUS_MOTIVO)
        VALUES (1, X.N_COD_CONTRATO, V_COD_USUARIO_LOGADO, SYSDATE, 88);
     END LOOP;
           
     UPDATE PLA_OCORRENCIAS
        SET N_COD_TIPO_OCOR = 262,
            N_COD_USUARIO_LOGADO = V_COD_USUARIO_LOGADO,
            D_OCORRENCIA = SYSDATE
      WHERE N_COD_TIPO_OCOR = 261
        AND N_COD_CONTRATO = V_COD_CONTRATO;
           
     UPDATE PLA_OCORRENCIAS
        SET N_COD_TIPO_OCOR = 342,
            N_COD_USUARIO_LOGADO = V_COD_USUARIO_LOGADO,
            D_OCORRENCIA = SYSDATE
      WHERE N_COD_TIPO_OCOR = 341
        AND N_COD_CONTRATO = V_COD_CONTRATO;
              
     UPDATE PLA_OCORRENCIAS
        SET N_COD_TIPO_OCOR = 383,
            N_COD_USUARIO_LOGADO = V_COD_USUARIO_LOGADO,
            D_OCORRENCIA = SYSDATE
      WHERE N_COD_TIPO_OCOR = 382
        AND N_COD_CONTRATO = V_COD_CONTRATO;
              
     UPDATE PLA_OCORRENCIAS
        SET N_COD_TIPO_OCOR = 386,
            N_COD_USUARIO_LOGADO = V_COD_USUARIO_LOGADO,
            D_OCORRENCIA = SYSDATE
      WHERE N_COD_TIPO_OCOR = 385
        AND N_COD_CONTRATO = V_COD_CONTRATO;
        
      IF V_COD_GRUPO_VENDA = 26 THEN
        --ENCAMINHAR PARA POS VENDA
        INSERT INTO PLA_OCORRENCIAS PO 
        (N_COD_TIPO_OCOR, N_COD_CONTRATO, D_OCORRENCIA, C_OCORRENCIA, N_COD_USUARIO_LOGADO, N_COD_SUB_ORIGEM)
        VALUES (398, V_COD_CONTRATO, SYSDATE, 'ENCAMINHADO NA CONFIRMACAO DE ASSINATURA', V_COD_USUARIO_LOGADO, 7);
      END IF;

      COMMIT;
   END IF;
  END IF;
  CLOSE CUR_CONTRATO;  
  
EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;

  V_ERRO_TMP := 'CODIGO '||SQLCODE||' -ERROR- '||SQLERRM  ||' -PARAMETROS-'||
                V_COD_CONTRATO ||'|'|| V_NOVA_DATA_VENDA ||'|'||
                V_NOVA_DATA_CARENCIA ||'|'|| V_NOVO_PRIM_VENCTO ||'|'||                
                V_DATA_VENDA_ATUAL ||'|'|| V_CARENCIA_ATUAL ||'|'||
                V_PRIMEIRO_VENCTO_ATUAL ||'|'|| V_DATA_ATIVACAO ||'|'||
                V_MIGRACAO ||'|';

  INSERT INTO ATHIA.G_ENVIO_EMAIL T
    (T.C_ASSUNTO, T.C_EMAIL_DESTINO, T.C_EMAIL_ORIGEM, T.C_MENSAGEM)
    VALUES ('PLA_SP_CONFIRMACAO_ASSINATURA','desenvolvimento@athia.com.br',
            'desenvolvimento@athia.com.br',V_ERRO_TMP);
  COMMIT;
END;
