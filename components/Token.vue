<template>
  <div>
    <div class="box">
      <div class="columns">
        <div class="column">
          Autenticação de duas etapas
          <br>
          <p>Um código de autenticação será enviado para o número de celular: ({{ telefone[0] }}{{ telefone[1] }})
            {{ telefone[2] }}{{ telefone[3] }}{{ telefone[4] }}{{ telefone[5] }}{{ telefone[6] }}-{{ telefone[7] }}{{
              telefone[8] }}{{ telefone[9] }}{{ telefone[10] }}
          </p>

          <button v-if="!this.$store.state.proposta.verificado" :disabled="clicou" class="button is-primary"
            @click="callPhone()">Enviar código</button>

          <span v-if="clicou && !this.$store.state.proposta.verificado">
            {{ tempoFormatado }}
          </span>


          <div class="columns">
            <div class="column">
              <AuthToken @change="updateAuth" v-if="temptoken != '' && !this.$store.state.proposta.verificado"
                :pass="temptoken" :disable="this.$store.state.proposta.verificado" />
            </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import AnexoDoc from "./AnexoDoc";
import ExtraPessoa from "./ExtraPessoa";
import Swal from 'sweetalert2'
import { TheMask } from "vue-the-mask";
import setProposta from "~/mixins/setProposta";
import Url from '~/mixins/Url'
import criaProposta from "~/mixins/criaProposta";

export default {
  name: "Token"
  ,
  mixins: [setProposta, Url, criaProposta],
  props: ['telefone']
  ,
  computed: {
    tempoFormatado() {
      var m = parseInt(this.timer / 60) + "";
      var s = (this.timer % 60) + "";

      return m.padStart(2, "0") + this.sep + s.padStart(2, "0");
    },
  },
  methods: {

    async callPhone() {

      let generatedCode = this.getRndInteger();

      let mensagem = "Token de validacao proposta Athia: " + generatedCode;

      this.temptoken = generatedCode;

      let formData = new FormData();

      formData.append("app", "trysms");
      formData.append("celular", this.$store.state.proposta.celular);
      formData.append("mensagem", mensagem);
      formData.append("token", generatedCode);

      //@TODO POSSIVEL PONTO DE PROBLEMA CASO SMS NAO ENVIE

      await this.$axios.post('https://portal.athia.com.br/sms/sms_proposta.php', formData, {

        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      });
      /*
            //==============ENVIAR SMS PURO; DESENVOLVIMENTO SOMENTE
      
            let formSms = new FormData();
      
            formSms.append("app", "enviasms");
            formSms.append("celular", this.$store.state.proposta.celular);
            formSms.append("mensagem", mensagem);
      
            await this.$axios.post('https://portal.athia.com.br/sms/sms_proposta.php', formSms, {
      
              headers: {
                'Content-Type': 'multipart/form-data'
              }
            });
      
      
             ///======================================================
      */

      this.clicou = true;
      this.timer = 120;
      this.tick();

    },
    getRndInteger() {
      let min = 111111;
      let max = 999999;
      return Math.floor(Math.random() * (max - min + 1)) + min;
    },
    async validatatePhone(tk) {


      let formData = new FormData();

      formData.append("app", "validatoken");
      formData.append("celular", this.$store.state.proposta.celular);
      formData.append("token", tk);

      await this.$axios.post('https://portal.athia.com.br/sms/sms_proposta.php', formData, {

        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      }).then((response) => this.validaResponse(response));

    },
    updateValue(campo, value) {
      this.$emit("change", {
        campo: campo,
        valor: value,
      });
    },
    updateAuth({ validado, token }) {
      if (validado) {
        this.validatatePhone(token);
      }

    },

    validaResponse(response) {
      if (response.data == '1') {
        this.update("verificado", true);
        this.submit();
        this
        Swal.fire({
          icon: 'success',
          title: 'Sucesso!',
          text: 'Número validado com sucesso!',
        })
      } else {
        Swal.fire({
          icon: 'error',
          title: 'Falha',
          text: 'Token inválido!',
        })
      }
    },

    async submit() {
      await this.createProposta();
    },
    tickSep() {
      setTimeout(() => {
        if (this.tempo > 0) {
          this.sep = this.sep == " " ? ":" : " ";
          this.tickSep();
        } else this.sep = ":";
      }, 500);
    },

    tick() {
      setTimeout(() => {
        this.timer--;
        if (this.timer > 0) {
          this.tick();
        } else {
          this.clicou = false;
        }
      }, 1000);
    },
  },
  components: { TheMask },
  data() {
    return {
      validador: 0,
      clicou: false,
      timer: 120,
      temptoken: 0,
      sep: ':'
    }
  },
  mounted() {

  }

}
</script>
<style scoped></style>
