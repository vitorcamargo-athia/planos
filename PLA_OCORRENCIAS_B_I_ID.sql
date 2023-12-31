CREATE OR REPLACE TRIGGER PLA_OCORRENCIAS_B_I_ID
  BEFORE INSERT OR DELETE OR UPDATE ON PLA_OCORRENCIAS
  FOR EACH ROW
DECLARE
  V_QTD NUMBER(3);
  V_AUTOMATICA NUMBER(1);
  V_VENDEDOR_CREMACAO NUMBER(10);
  V_DEST_ANTERIOR     VARCHAR2(200);
  V_DEST_ATUAL        VARCHAR2(200);
  V_DEST_OCOR         VARCHAR2(400);
  V_DEST_OCOR_OLD     VARCHAR2(400);
  V_DEST_OCOR_NEW     VARCHAR2(400);
  
  CURSOR CUR_TIPO_OCOR(V_COD_TIPO_OCOR NUMBER) IS
    SELECT T.F_AUTOMATICA, T.C_OCORRENCIA
      FROM PLA_TIPO_OCORRENCIA T
     WHERE T.N_COD_TIPO_OCOR = V_COD_TIPO_OCOR;     
     
  CURSOR CUR_VENDEDOR_CREMACAO IS 
    SELECT S.N_COD_VENDEDOR 
      FROM PLA_SERVICOS_AUTORIZADOS S
     WHERE S.N_COD_TIPO_SERVICO = 23
       AND S.D_FINAL IS NULL
       AND S.N_COD_CONTRATO = :NEW.N_COD_CONTRATO;
       
  CURSOR CUR_USUARIO_DESTINO(V_COD_USU NUMBER) IS
    SELECT NP1.C_NOME_RAZAO_SOCIAL
      FROM GER_USUARIO U1
             INNER JOIN GER_NOME_PESSOA NP1
              ON (NP1.D_VALIDADE_FINAL IS NULL
                  AND NP1.N_COD_PESSOA = U1.N_COD_PESSOA)
     WHERE U1.N_COD_USUARIO = V_COD_USU;

BEGIN
  IF INSERTING THEN
    SSO_SP_MOVIMENTACAO_OCOR(:NEW.N_COD_USUARIO_LOGADO,:NEW.N_COD_TIPO_OCOR,:NEW.N_COD_SUB_ORIGEM,
                             NVL(:NEW.N_COD_SOL_BENEF,0),NVL(:NEW.N_COD_BENEF_CESTA,0),NVL(:NEW.N_COD_BENEF_REMIS,0),
                             NVL(:NEW.N_COD_BENEF_DESEM,0),NVL(:NEW.N_COD_BENEF_D_INTER,0),NVL(:NEW.N_COD_BENEF_F_OSEA,0),
                             NVL(:NEW.N_COD_CONTROLE_REPASSE,0),NVL(:NEW.N_COD_CONTEMPLADO,0),'M');
                             
    IF :NEW.N_COD_TIPO_OCOR = 312 THEN
      :NEW.N_COD_TIPO_OCOR_SUB := 88;
    END IF;
    
    IF :NEW.N_COD_TIPO_OCOR = 359 OR :NEW.N_COD_TIPO_OCOR = 360 THEN
      :NEW.N_COD_TIPO_OCOR_SUB := 130;
    END IF;
    
    IF :NEW.N_COD_TIPO_OCOR_SUB = 68 AND :NEW.N_COD_TIPO_OCOR = 339 THEN
      --NÃO TEM INTERSSE NA CREMAÇÃO, PRORROGAR NOVO CONTATO PARA 6 MESES
      :NEW.D_NAO_COBRAR_ATE := TRUNC((SYSDATE) + 180);
    END IF;

    SELECT N_COD_OCOR_SEQ.NEXTVAL INTO :NEW.N_COD_OCORRENCIA FROM DUAL;
    IF :NEW.D_OCORRENCIA IS NULL THEN
      :NEW.D_OCORRENCIA := SYSDATE;
    END IF;
    
    SELECT COUNT(1) INTO V_QTD 
      FROM PLA_TIPO_OCORRENCIA T
     WHERE T.N_COD_TIPO_OCOR NOT IN (156,263) --156 POS AUTOMATICO E 263 REPIQUE
       AND T.N_COD_VISUALIZACAO = 3
       AND T.N_COD_TIPO_OCOR = :NEW.N_COD_TIPO_OCOR;
    IF V_QTD > 0 THEN
      UPDATE PLA_AVISO_X_CONTRATO 
         SET F_AVISADO_SN = 'S', N_COD_USUARIO_AVISOU = :NEW.N_COD_USUARIO_LOGADO
       WHERE F_AVISADO_SN = 'N'
         AND N_COD_AVISO = 6
         AND N_COD_CONTRATO = :NEW.N_COD_CONTRATO;
    END IF;
    
    PLA_CONTRATO_PACK.V_NUMENTRIES := 1;
    PLA_CONTRATO_PACK.V_N_COD_CONTRATO(PLA_CONTRATO_PACK.V_NUMENTRIES) := :NEW.N_COD_CONTRATO;
    PLA_CONTRATO_PACK.V_NAO_COBRAR_ATE(PLA_CONTRATO_PACK.V_NUMENTRIES) := :NEW.D_NAO_COBRAR_ATE;
    PLA_CONTRATO_PACK.V_D_OCORRENCIA_NEW(PLA_CONTRATO_PACK.V_NUMENTRIES) := :NEW.D_OCORRENCIA;
    PLA_CONTRATO_PACK.V_N_COD_USUARIO_LOGADO(PLA_CONTRATO_PACK.V_NUMENTRIES) := :NEW.N_COD_USUARIO_LOGADO;
    PLA_CONTRATO_PACK.V_N_COD_OCORRENCIA(PLA_CONTRATO_PACK.V_NUMENTRIES) := :NEW.N_COD_OCORRENCIA;
    PLA_CONTRATO_PACK.V_N_COD_TIPO_OCOR_NEW(PLA_CONTRATO_PACK.V_NUMENTRIES) := :NEW.N_COD_TIPO_OCOR;
    PLA_CONTRATO_PACK.V_COD_SUB_ORIGEM(PLA_CONTRATO_PACK.V_NUMENTRIES) := :NEW.N_COD_SUB_ORIGEM;
    PLA_CONTRATO_PACK.V_N_COD_USUARIO_DESTINO(PLA_CONTRATO_PACK.V_NUMENTRIES) := :NEW.N_COD_USUARIO_DESTINO;
    
    --ACORDO DE RESSARCIMENTO PARA PLANO EXECUTIVO - PREMIUM
    IF :NEW.N_COD_TIPO_OCOR = 200 AND :NEW.N_COD_TIPO_PLANO = 6 THEN
      --CANCELA SERGURO NO VALOR DE 2000,00
      IF :NEW.N_COD_SUB_ORIGEM = 10 THEN
        UPDATE PLA_SERVICOS_AUTORIZADOS S
             SET S.D_FINAL = (TRUNC(SYSDATE)-2)
           WHERE S.N_COD_TIPO_SERVICO = 3
             AND S.N_COD_CONTRATO = :NEW.N_COD_CONTRATO;
      ELSE
        UPDATE PLA_SERVICOS_AUTORIZADOS S
             SET S.D_FINAL = (TRUNC(SYSDATE)-1)
           WHERE S.N_COD_TIPO_SERVICO = 3
             AND S.N_COD_CONTRATO = :NEW.N_COD_CONTRATO;
      END IF;
      --LIBERA SERGURO NO VALOR DE 3000,00
      INSERT INTO PLA_SERVICOS_AUTORIZADOS
      (N_COD_TIPO_SERVICO, N_COD_CONTRATO, D_INICIAL, N_COD_USUARIO_LOGADO)
      VALUES (4,:NEW.N_COD_CONTRATO,TRUNC(SYSDATE),:NEW.N_COD_USUARIO_LOGADO);
    END IF;
    
    IF :NEW.N_COD_TIPO_OCOR = 337 THEN
      OPEN CUR_VENDEDOR_CREMACAO;
      FETCH CUR_VENDEDOR_CREMACAO INTO V_VENDEDOR_CREMACAO;
      IF CUR_VENDEDOR_CREMACAO%FOUND THEN
        :NEW.N_COD_VENDEDOR := V_VENDEDOR_CREMACAO;
      END IF;
      CLOSE CUR_VENDEDOR_CREMACAO;
    END IF;
    
    IF :NEW.N_COD_TIPO_OCOR = 330 AND :NEW.N_COD_TIPO_OCOR_SUB = 148 THEN
      SELECT (CASE
               WHEN TO_CHAR(SYSDATE,'DD') <= 30 
                 THEN TO_DATE(30 || '/' || TRIM(TO_CHAR(SYSDATE,'MM/RRRR')),'DD/MM/RRRR')
               WHEN TO_CHAR(SYSDATE,'DD') > 30
                 THEN TRUNC(LAST_DAY(SYSDATE)+30)
              END)
        INTO :NEW.D_PROGRAMACAO_VISITA
        FROM DUAL;
    END IF;
  END IF;
  
  IF UPDATING THEN
    SSO_SP_MOVIMENTACAO_OCOR(:NEW.N_COD_USUARIO_LOGADO,:NEW.N_COD_TIPO_OCOR,:NEW.N_COD_SUB_ORIGEM,
                             NVL(:NEW.N_COD_SOL_BENEF,0),NVL(:NEW.N_COD_BENEF_CESTA,0),NVL(:NEW.N_COD_BENEF_REMIS,0),
                             NVL(:NEW.N_COD_BENEF_DESEM,0),NVL(:NEW.N_COD_BENEF_D_INTER,0),NVL(:NEW.N_COD_BENEF_F_OSEA,0),
                             NVL(:NEW.N_COD_CONTROLE_REPASSE,0));
  
    IF :OLD.N_COD_TIPO_OCOR = 282 THEN
      IF :NEW.N_COD_TIPO_OCOR <> 282 THEN
        RAISE_APPLICATION_ERROR(-20001,'NAO PODE SER ALTERADO O TIPO DA OCORRENCIA.');
      END IF; 
      
      IF :OLD.N_COD_TIPO_OCOR_SUB NOT IN (67,3) AND :NEW.N_COD_TIPO_OCOR_SUB IN (67,3) THEN
        RAISE_APPLICATION_ERROR(-20001,'NAO ESTA AUTORIZADO A VOLTAR PARA PENDENTE.');
      END IF; 
    END IF;  
  
    IF :NEW.N_COD_TIPO_OCOR = 276 AND :NEW.N_COD_SUB_ORIGEM <> 14 THEN
      :NEW.N_COD_SUB_ORIGEM := 14;
    END IF;
    
    IF :NEW.N_COD_TIPO_OCOR IN (359,360) AND :NEW.N_COD_TIPO_OCOR NOT IN (359,360) THEN
      :NEW.N_COD_USUARIO_DESTINO := NULL;
      :NEW.N_COD_OCORRENCIA_REFERENCIA := NULL;
    END IF;
  
    OPEN CUR_TIPO_OCOR(:OLD.N_COD_TIPO_OCOR);
    FETCH CUR_TIPO_OCOR INTO V_AUTOMATICA, V_DEST_OCOR;
    CLOSE CUR_TIPO_OCOR;
    IF V_AUTOMATICA = 1 AND :OLD.N_COD_TIPO_OCOR NOT IN (115,282,306,307,308,401) THEN
      IF NOT((:OLD.N_COD_TIPO_OCOR = 427 AND :NEW.N_COD_TIPO_OCOR = 427) OR 
             (:OLD.N_COD_TIPO_OCOR = 262 AND :NEW.N_COD_TIPO_OCOR = 427) OR 
             (:OLD.N_COD_TIPO_OCOR = 200 AND :NEW.N_COD_TIPO_OCOR = 204) OR
             (:OLD.N_COD_TIPO_OCOR = 233 AND :NEW.N_COD_TIPO_OCOR = 234) OR
             (:OLD.N_COD_TIPO_OCOR = 250 AND :NEW.N_COD_TIPO_OCOR = 265) OR
             (:OLD.N_COD_TIPO_OCOR = 341 AND :NEW.N_COD_TIPO_OCOR = 432) OR
             (:OLD.N_COD_TIPO_OCOR = 261 AND :NEW.N_COD_TIPO_OCOR = 427) OR
             (:OLD.N_COD_TIPO_OCOR = 427 AND :NEW.N_COD_TIPO_OCOR = 262) OR
             (:OLD.N_COD_TIPO_OCOR = 261 AND :NEW.N_COD_TIPO_OCOR = 262) OR
             (:OLD.N_COD_TIPO_OCOR = 262 AND :NEW.N_COD_TIPO_OCOR = 261) OR
             (:OLD.N_COD_TIPO_OCOR = 341 AND :NEW.N_COD_TIPO_OCOR IN (338,342,350)) OR
             (:OLD.N_COD_TIPO_OCOR = 382 AND :NEW.N_COD_TIPO_OCOR IN (389,383,384)) OR
             (:OLD.N_COD_TIPO_OCOR = 385 AND :NEW.N_COD_TIPO_OCOR IN (390,386,387)) OR
             (:OLD.N_COD_TIPO_OCOR = 343 AND :NEW.N_COD_TIPO_OCOR = 344) OR
             (:OLD.N_COD_TIPO_OCOR = 275 AND :NEW.N_COD_TIPO_OCOR = 276) OR
             (:OLD.N_COD_TIPO_OCOR = 283 AND :NEW.N_COD_TIPO_OCOR = 284) OR
             (:OLD.N_COD_TIPO_OCOR = 245 AND :NEW.N_COD_TIPO_OCOR = 302) OR
             (:OLD.N_COD_TIPO_OCOR = 267 AND :NEW.N_COD_TIPO_OCOR = 268)
             /*AND TRUNC(:OLD.D_OCORRENCIA) = TRUNC(SYSDATE)*/) THEN --CANCELAMENTO DE ACORDO
         IF NOT(:OLD.N_COD_TIPO_OCOR = 402 AND :OLD.N_COD_TIPO_OCOR_SUB = 146) AND
            NOT(:OLD.N_COD_TIPO_OCOR = 358 AND :OLD.N_COD_TIPO_OCOR_SUB = 98 AND :NEW.N_COD_TIPO_OCOR_SUB IN (99,100)) AND
            NOT(:OLD.N_COD_TIPO_OCOR = 241 AND :NEW.N_COD_TIPO_OCOR = 241 AND :OLD.N_COD_TIPO_OCOR_SUB IN (25,46) AND :NEW.N_COD_TIPO_OCOR_SUB = 59) AND
            NOT(:OLD.N_COD_TIPO_OCOR = 326 AND :NEW.N_COD_TIPO_OCOR = 326 AND :OLD.N_COD_TIPO_OCOR_SUB = 98 AND :NEW.N_COD_TIPO_OCOR_SUB IN (99,100)) AND
            NOT(:OLD.N_COD_TIPO_OCOR = 327 AND :NEW.N_COD_TIPO_OCOR = 327 AND :OLD.N_COD_TIPO_OCOR_SUB = 98 AND :NEW.N_COD_TIPO_OCOR_SUB IN (99,100)) AND
            NOT(:NEW.N_COD_TIPO_OCOR IN (246,256) AND :OLD.N_COD_TIPO_OCOR_SUB <> 59 AND :NEW.N_COD_TIPO_OCOR_SUB = 59) THEN
           --NULL;
           RAISE_APPLICATION_ERROR(-20001,'OCORRENCIA AUTOMATICA NAO PODE SER ALTERADA.'||:OLD.N_COD_TIPO_OCOR||'|'||:NEW.N_COD_TIPO_OCOR);
         END IF;
      END IF;
    END IF;
    
    IF :OLD.N_COD_USUARIO_LOGADO <> :NEW.N_COD_USUARIO_LOGADO AND NVL(:NEW.N_COD_TIPO_OCOR_SUB,0) <> 59 THEN
      IF :OLD.N_COD_TIPO_OCOR_SUB = 3 AND :OLD.N_COD_OCORRENCIA_REFERENCIA IS NULL THEN
        --OCORRENCIA QUE ESTA PENDENTE RETORNAR LIGAC?O E PERMITIDO ALTERAR EM OUTRO DIA APENAS O CAMPO DE AUTENTICAC?O DE REFERENCIA
        :NEW.N_COD_TIPO_OCOR               := :OLD.N_COD_TIPO_OCOR;
        :NEW.D_OCORRENCIA                  := :OLD.D_OCORRENCIA;
        :NEW.N_COD_USUARIO_LOGADO          := :OLD.N_COD_USUARIO_LOGADO;
        :NEW.C_OCORRENCIA                  := :OLD.C_OCORRENCIA;
        :NEW.D_DATA_CANCELAMENTO           := :OLD.D_DATA_CANCELAMENTO;
        :NEW.D_DATA_FIM_CARENCIA           := :OLD.D_DATA_FIM_CARENCIA;
        :NEW.N_COD_TIPO_PLANO              := :OLD.N_COD_TIPO_PLANO;
        :NEW.N_COD_CONTRATO                := :OLD.N_COD_CONTRATO;
        :NEW.D_PROGRAMACAO_VISITA          := :OLD.D_PROGRAMACAO_VISITA;
        :NEW.N_COD_CAMPANHA                := :OLD.N_COD_CAMPANHA;
        :NEW.N_COD_VENDEDOR                := :OLD.N_COD_VENDEDOR;
        :NEW.N_COD_IMPORTACAO              := :OLD.N_COD_IMPORTACAO;
        :NEW.N_COD_IMP_TELCOB              := :OLD.N_COD_IMP_TELCOB;
        :NEW.D_NAO_COBRAR_ATE              := :OLD.D_NAO_COBRAR_ATE;
        :NEW.N_COD_SMS                     := :OLD.N_COD_SMS;
        :NEW.N_COD_TIPO_OCOR_SUB           := :OLD.N_COD_TIPO_OCOR_SUB;
        :NEW.N_COD_SUB_ORIGEM              := :OLD.N_COD_SUB_ORIGEM;
        :NEW.N_COD_CONTRATO_REFERENCIA     := :OLD.N_COD_CONTRATO_REFERENCIA;
      ELSE
        IF :OLD.N_COD_TIPO_OCOR NOT IN (403,261,341,343,265,267,275,282,283,306,307,251,312,332,382,383,385,386,401) THEN
          RAISE_APPLICATION_ERROR(-20001,'OCORRENCIA PODE SER ALTERADA APENAS PELO PROPRIO USUARIO.');
          --NULL;
        END IF;
      END IF;
    END IF;
    IF TRUNC(SYSDATE) <> TRUNC(:OLD.D_OCORRENCIA) THEN
      IF :OLD.N_COD_TIPO_OCOR_SUB = 3 AND :OLD.N_COD_OCORRENCIA_REFERENCIA IS NULL THEN
        --OCORRENCIA QUE ESTA PENDENTE RETORNAR LIGAC?O E PERMITIDO ALTERAR EM OUTRO DIA APENAS O CAMPO DE AUTENTICAC?O DE REFERENCIA
        :NEW.N_COD_TIPO_OCOR               := :OLD.N_COD_TIPO_OCOR;
        :NEW.D_OCORRENCIA                  := :OLD.D_OCORRENCIA;
        :NEW.N_COD_USUARIO_LOGADO          := :OLD.N_COD_USUARIO_LOGADO;
        :NEW.C_OCORRENCIA                  := :OLD.C_OCORRENCIA;
        :NEW.D_DATA_CANCELAMENTO           := :OLD.D_DATA_CANCELAMENTO;
        :NEW.D_DATA_FIM_CARENCIA           := :OLD.D_DATA_FIM_CARENCIA;
        :NEW.N_COD_TIPO_PLANO              := :OLD.N_COD_TIPO_PLANO;
        :NEW.N_COD_CONTRATO                := :OLD.N_COD_CONTRATO;
        :NEW.D_PROGRAMACAO_VISITA          := :OLD.D_PROGRAMACAO_VISITA;
        :NEW.N_COD_CAMPANHA                := :OLD.N_COD_CAMPANHA;
        :NEW.N_COD_VENDEDOR                := :OLD.N_COD_VENDEDOR;
        :NEW.N_COD_IMPORTACAO              := :OLD.N_COD_IMPORTACAO;
        :NEW.N_COD_IMP_TELCOB              := :OLD.N_COD_IMP_TELCOB;
        :NEW.D_NAO_COBRAR_ATE              := :OLD.D_NAO_COBRAR_ATE;
        :NEW.N_COD_SMS                     := :OLD.N_COD_SMS;
        :NEW.N_COD_TIPO_OCOR_SUB           := :OLD.N_COD_TIPO_OCOR_SUB;
        :NEW.N_COD_SUB_ORIGEM              := :OLD.N_COD_SUB_ORIGEM;
        :NEW.N_COD_CONTRATO_REFERENCIA     := :OLD.N_COD_CONTRATO_REFERENCIA;
      ELSE
         IF :OLD.N_COD_TIPO_OCOR NOT IN (154,132,115,261,341,343,267,282,283,245,306,251,312,326,327,359,360,382,383,385,386,401) THEN
           IF NOT((:OLD.N_COD_TIPO_OCOR = 402 AND :OLD.N_COD_TIPO_OCOR_SUB = 146) OR
                  (:OLD.N_COD_TIPO_OCOR = 200 AND :NEW.N_COD_TIPO_OCOR = 204) OR
                  (:OLD.N_COD_TIPO_OCOR = 250 AND :NEW.N_COD_TIPO_OCOR = 265) OR
                  (:OLD.N_COD_TIPO_OCOR = 275 AND :NEW.N_COD_TIPO_OCOR = 276) OR
                 (:OLD.N_COD_TIPO_OCOR = 261 AND :NEW.N_COD_TIPO_OCOR = 427) OR
                  (:OLD.N_COD_TIPO_OCOR = 341 AND :NEW.N_COD_TIPO_OCOR = 432) OR
                 (:OLD.N_COD_TIPO_OCOR = 427 AND :NEW.N_COD_TIPO_OCOR = 262) OR
                 (:OLD.N_COD_TIPO_OCOR = 262 AND :NEW.N_COD_TIPO_OCOR = 427) OR 
                  (:OLD.N_COD_TIPO_OCOR = 233 AND :NEW.N_COD_TIPO_OCOR = 234) 
                 /* AND TRUNC(:OLD.D_OCORRENCIA) = TRUNC(SYSDATE)*/) THEN --CANCELAMENTO DE ACORDO
             IF NOT(:OLD.N_COD_TIPO_OCOR = 403 AND ((:NEW.N_QTD_ENVIO <> :OLD.N_QTD_ENVIO) OR (:OLD.N_COD_TIPO_OCOR_SUB = 149 AND :NEW.N_COD_TIPO_OCOR_SUB IN (150,151)))) AND
                NOT(:OLD.N_COD_TIPO_OCOR = 358 AND :OLD.N_COD_TIPO_OCOR_SUB = 98 AND :NEW.N_COD_TIPO_OCOR_SUB IN (99,100)) AND
                NOT(:OLD.N_COD_TIPO_OCOR = 241 AND :NEW.N_COD_TIPO_OCOR = 241 AND :OLD.N_COD_TIPO_OCOR_SUB IN (25,46) AND :NEW.N_COD_TIPO_OCOR_SUB = 59) AND 
                NOT(:OLD.N_COD_TIPO_OCOR = 304 AND :NEW.N_COD_TIPO_OCOR = 304 AND :OLD.N_COD_TIPO_OCOR_SUB IN (26,46,77) AND :NEW.N_COD_TIPO_OCOR_SUB = 59) AND
                NOT(:OLD.N_COD_TIPO_OCOR = 332 AND :NEW.N_COD_TIPO_OCOR = 332 AND :OLD.N_COD_TIPO_OCOR_SUB = 104 AND :NEW.N_COD_TIPO_OCOR_SUB = 105) AND
                NOT(:NEW.N_COD_TIPO_OCOR IN (246,256) AND :OLD.N_COD_TIPO_OCOR_SUB <> 59 AND :NEW.N_COD_TIPO_OCOR_SUB = 59) AND 
                NOT(:OLD.N_COD_TIPO_OCOR = 424) AND
                NOT(:OLD.D_NAO_COBRAR_ATE = '31/12/2222' AND :NEW.D_NAO_COBRAR_ATE <> '31/12/2222' AND :NEW.N_COD_SUB_ORIGEM = 82) AND
                :NEW.N_COD_TIPO_OCOR <> 416 THEN
               RAISE_APPLICATION_ERROR(-20001,'OCORRENCIA PODE SER ALTERADA APENAS APENAS NO DIA DO CADASTRO.');
               --NULL;
             END IF;
           END IF;
         END IF;
         --NULL;
      END IF;
    END IF;
    
    IF NVL(:OLD.N_COD_USUARIO_DESTINO,0) <> NVL(:NEW.N_COD_USUARIO_DESTINO,0) THEN
      OPEN CUR_USUARIO_DESTINO(NVL(:OLD.N_COD_USUARIO_DESTINO,-1));
      FETCH CUR_USUARIO_DESTINO INTO V_DEST_ANTERIOR;
      IF CUR_USUARIO_DESTINO%NOTFOUND THEN
        V_DEST_ANTERIOR:= 'EM BRANCO';
      END IF;
      CLOSE CUR_USUARIO_DESTINO;
      
      OPEN CUR_USUARIO_DESTINO(NVL(:NEW.N_COD_USUARIO_DESTINO,-1));
      FETCH CUR_USUARIO_DESTINO INTO V_DEST_ATUAL;
      IF CUR_USUARIO_DESTINO%NOTFOUND THEN
        V_DEST_ATUAL:= 'EM BRANCO';
      END IF;
      CLOSE CUR_USUARIO_DESTINO;
      
      :NEW.C_OCORRENCIA := :NEW.C_OCORRENCIA || ' - DESTINO ALTERADO DE ' 
                           || V_DEST_ANTERIOR || ' PARA ' || V_DEST_ATUAL;
    END IF;
    
    IF :OLD.N_COD_TIPO_OCOR <> :NEW.N_COD_TIPO_OCOR THEN
      OPEN CUR_TIPO_OCOR(:OLD.N_COD_TIPO_OCOR);
      FETCH CUR_TIPO_OCOR INTO V_AUTOMATICA, V_DEST_OCOR_OLD;
      CLOSE CUR_TIPO_OCOR;
      
      OPEN CUR_TIPO_OCOR(:NEW.N_COD_TIPO_OCOR);
      FETCH CUR_TIPO_OCOR INTO V_AUTOMATICA, V_DEST_OCOR_NEW;
      CLOSE CUR_TIPO_OCOR;
      
      :NEW.C_OCORRENCIA := :NEW.C_OCORRENCIA || ' (TIPO ALTERADO DE '|| V_DEST_OCOR_OLD ||' PARA '|| V_DEST_OCOR_NEW ||' AS '|| TRIM(TO_CHAR(SYSDATE,'DD/MM/RR HH24:MM')) ||') ';
      
    END IF;
    
    IF :NEW.N_COD_TIPO_OCOR = 330 AND :NEW.N_COD_TIPO_OCOR_SUB = 148 AND
       :OLD.D_PROGRAMACAO_VISITA <> :NEW.D_PROGRAMACAO_VISITA THEN
      SELECT (CASE
               WHEN TO_CHAR(SYSDATE,'DD') <= 30 
                 THEN TO_DATE(30 || '/' || TRIM(TO_CHAR(SYSDATE,'MM/RRRR')),'DD/MM/RRRR')
               WHEN TO_CHAR(SYSDATE,'DD') > 30
                 THEN TRUNC(LAST_DAY(SYSDATE)+30)
              END)
        INTO :NEW.D_PROGRAMACAO_VISITA
        FROM DUAL;
    END IF;
  END IF;
  
  IF DELETING THEN
    SELECT COUNT(1) INTO V_QTD FROM PLA_CONTRATO_PESSOA
     WHERE N_COD_CONTRATO = :OLD.N_COD_CONTRATO;
    IF V_QTD > 0 THEN
      OPEN CUR_TIPO_OCOR(:OLD.N_COD_TIPO_OCOR);
      FETCH CUR_TIPO_OCOR INTO V_AUTOMATICA, V_DEST_OCOR;
      CLOSE CUR_TIPO_OCOR;
    
      IF V_AUTOMATICA = 1 AND :OLD.N_COD_TIPO_OCOR NOT IN (115,211,306,433) AND :OLD.N_COD_USUARIO_LOGADO <> 177 THEN
        --NULL;
        RAISE_APPLICATION_ERROR(-20001,'OCORRENCIA AUTOMATICA NAO PODE SER EXCLUIDA.');
      ELSE
        DELETE FROM PLA_OCORRENCIAS_PARCELAS I 
         WHERE I.N_COD_OCORRENCIA = :OLD.N_COD_OCORRENCIA;
      END IF;
    ELSE
      IF TRUNC(:NEW.D_OCORRENCIA) < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20001,'OCORRENCIA PODE SER EXCLUIDA APENAS NO DIA DO CADASTRO.');
      ELSE
         
         DELETE FROM PLA_OCORRENCIAS_PARCELAS I WHERE I.N_COD_OCORRENCIA = :OLD.N_COD_OCORRENCIA;
         
      END IF;
    END IF;
  END IF;
    
END;

