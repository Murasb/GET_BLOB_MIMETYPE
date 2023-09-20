SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FNC_GET_BLOB_MIMETYPE ( P_BLOB IN BLOB ) RETURN VARCHAR2 
AS 
   V_BLOB BLOB;
   V_RAW RAW(32767);
   V_BUFFER RAW(32767); -- Buffer para ler os primeiros bytes do BLOB
   V_AMOUNT NUMBER;
   V_OFFSET NUMBER := 1;
   V_MIME_TYPE VARCHAR2(100);
   
BEGIN

    V_BLOB := P_BLOB;

   -- Leitura dos primeiros bytes do BLOB
   V_AMOUNT := DBMS_LOB.GETLENGTH(V_BLOB);

   IF V_AMOUNT >= 4 THEN
      -- Limita a leitura a 4 bytes
      V_AMOUNT := LEAST(4, V_AMOUNT);

      -- Lê os primeiros bytes do BLOB em um buffer
      DBMS_LOB.READ(V_BLOB, V_AMOUNT, V_OFFSET, V_BUFFER);

      -- Verifica os bytes lidos para identificar o mimetype
      IF V_BUFFER = HEXTORAW('FFD8FFDB') THEN
         V_MIME_TYPE := 'image/jpeg';
      ELSIF V_BUFFER = HEXTORAW('FFD8FFE0') THEN
         V_MIME_TYPE := 'image/jpg'; -- JPG com tipo 'FFD8FFE0'
      ELSIF V_BUFFER = HEXTORAW('89504E47') THEN
         V_MIME_TYPE := 'image/png';
      ELSIF V_BUFFER = HEXTORAW('25504446') THEN
         V_MIME_TYPE := 'application/pdf'; -- PDF

      -- Adicione mais verificações para outros tipos de arquivo, se necessário
      ELSE
         V_MIME_TYPE := 'application/octet-stream'; -- Tipo desconhecido
      END IF;
   ELSE
      V_MIME_TYPE := 'application/octet-stream  v_amount=>'||TO_NUMBER(V_AMOUNT); -- Tipo desconhecido
   END IF; 

  RETURN V_MIME_TYPE;
END FNC_GET_BLOB_MIMETYPE;
/