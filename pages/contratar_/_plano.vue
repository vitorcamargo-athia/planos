<template>
  <div class="columns">

    <div class="column">

      <h5 v-if="possuiVendedor" class="title is-5 has-text-centered">Vendedor: {{ vendedorNome }} </h5>
      <div class="control">
        <div>
          <section>
            <b-steps v-if="visivel" v-model="activeStep" :animated="isAnimated" :rounded="isRounded"
              :has-navigation="hasNavigation" :icon-prev="prevIcon" :icon-next="nextIcon" :label-position="labelPosition"
              :mobile-mode="mobileMode">

              <b-step-item :step="1" label="Questionário" :clickable="isStepsClickable">
                <Perguntas ref="perguntas" @change="updateValue" @atualizaIndices="espaco" />
              </b-step-item>

              <b-step-item :step="2" label="Informações Pessoais" :clickable="isStepsClickable"
                :type="{ 'is-success': isProfileSuccess }">
                <Pessoa :filhos="dadosForm.filhos" :conjuge="dadosForm.conjugue" ref="pessoa" :indices="indices"
                  @change="updateValue" />
              </b-step-item>

              <b-step-item v-if="this.$route.query.plano != 'Essencial'" :step="3" label="Informações do beneficiário"
                :clickable="isStepsClickable">
                <Beneficiario @change="updateValue" />
              </b-step-item>

              <b-step-item :step="stepCobranca" label="Cobrança" :clickable="isStepsClickable">
                <Cobranca @change="updateValue" :telefone="this.dadosForm['celular']" />
              </b-step-item>
              <template #navigation="{ previous, next }">
                <b-button outlined type="is-primary" :disabled="previous.disabled" @click.prevent="previous.action">
                  Voltar
                </b-button>
                <b-button outlined type="is-primary" :disabled="next.disabled" @click="scrollTopAndVerify">
                  Avançar
                </b-button>
              </template>
            </b-steps>
          </section>
        </div>

      </div>

    </div>

  </div>
</template>

<script>
import Swal from 'sweetalert2'
import setProposta from "~/mixins/setProposta";
import Endereco from "../../components/Beneficiario.vue";
import Finalizacao from "../../components/Finalizacao";
import call from "../../api";
import { cpf } from "cpf-cnpj-validator";

export default {
  components: { Finalizacao, Endereco },
  mixins: [setProposta],
  updated() {

  },

  data() {
    return {

      indices: {
        conjuge: -1,
        dpai: -1,
        dmae: -1,
        dsogro: -1,
        dsogra: -1,
        outros: -1
      },

      posts: [],
      liberado: false,
      visivel: false,
      currentVendedor: -1,
      vendedorNome: "",
      possuiVendedor: false,
      activeStep: 1,

      showSocial: false,
      isAnimated: true,
      isRounded: true,
      isStepsClickable: false,

      hasNavigation: true,
      customNavigation: false,
      isProfileSuccess: false,

      prevIcon: 'chevron-left',
      nextIcon: 'chevron-right',
      labelPosition: 'bottom',
      mobileMode: 'minimalist',

      dadosForm: {
        maiorIdade: false
      }
    }
  },
  name: "planoPage",
  computed: {
    stepCobranca() {
      return this.$route.query.plano != 'Essencial' ? 4 : 3;
    },
  },
  methods: {

    espaco() {
      let index = 0;

      let tempIndices = {};

      ['conjuge', 'dpai', 'dmae', 'dsogro', 'dsogra'].forEach(e => {
        let p = this.$store.state.proposta[e];
        if (p && p != 'false') {
          tempIndices[e] = index;

          index++
        }
        // console.log(e +" => "+this.$store.state.proposta[e]);
      })

      tempIndices.outros = index;

      let auxiliar = [];

      function getKeyByValue(object, value) {
        return Object.keys(object).find(key => object[key] === value);
      }

      let l = 0;

      for (let i = 0; i < this.$store.state.proposta.dependentes.length; i++) {
        if (i < this.indices.outros) {

          let chaves = getKeyByValue(this.indices, i);
          //   console.log("A chave => "+chaves)

          auxiliar[tempIndices[chaves]] = this.$store.state.proposta.dependentes[i];

          //  console.log("tempIndices[chaves] " + tempIndices[chaves])

        } else {

          if (l < this.$store.state.proposta.filhos) {
            auxiliar[tempIndices.outros + (l++)] = this.$store.state.proposta.dependentes[i];
          }
        }
      }
      this.update("dependentes", auxiliar);

      this.indices = tempIndices;

    },

    canGoNext() {
      let res = true;
      //Valida CPF
      if (!cpf.isValid(this.dadosForm["cpf"])) {
        res = false;
      }

      switch (this.activeStep) {
        case 0:
          if (this.dadosForm["maiorIdade"] == "s") {

            this.callIdadeAlert("O plano " + this.$route.query.plano + " não está disponível para maiores de 70 anos!");
            res = true;
          } else {
            res = true;
          }
          break;
        case 1:
          if (typeof this.dadosForm["nome"] === 'undefined' || this.dadosForm["nome"] === null || this.dadosForm["nome"] == "") {
            res = false;
          }

          if (typeof this.dadosForm["cpf"] === 'undefined' || this.dadosForm["cpf"] === null) {
            res = false;
          }

          if (typeof this.dadosForm["dataNasc"] === 'undefined' || this.dadosForm["dataNasc"] === null) {
            res = false;
          }

          if (typeof this.dadosForm["email"] === 'undefined' || this.dadosForm["email"] === null) {
            res = false;
          }

          if (typeof this.dadosForm["celular"] === 'undefined' || this.dadosForm["celular"] === null) {
            res = false;
          }

          if (typeof this.dadosForm["rg"] === 'undefined' || this.dadosForm["rg"] === null) {
            res = false;
          }

          if (typeof this.$store.state.proposta.cep === 'undefined' || this.$store.state.proposta.cep === null || this.$store.state.proposta.cep == "") {
            res = false;
          }

          if (typeof this.$store.state.proposta.logradouro === 'undefined' || this.$store.state.proposta.logradouro === null || this.$store.state.proposta.logradouro == "") {
            res = false;
          }

          if (typeof this.$store.state.proposta.numero === 'undefined' || this.$store.state.proposta.numero === null || this.$store.state.proposta.numero == "") {
            res = false;
          }

          if (typeof this.$store.state.proposta.bairro === 'undefined' || this.$store.state.proposta.bairro === null || this.$store.state.proposta.bairro == "") {
            res = false;
          }

          if (typeof this.$store.state.proposta.cidade === 'undefined' || this.$store.state.proposta.cidade === null || this.$store.state.proposta.cidade == "") {
            res = false;
          }

          if (typeof this.$store.state.proposta.uf === 'undefined' || this.$store.state.proposta.uf === null || this.$store.state.proposta.uf == "") {

          }

          let c = true;
          for (let index = 0; index < this.$store.state.proposta.dependentes.length && c; index++) {
            let d = this.$store.state.proposta.dependentes[index];
            c = (d.nome.length != 0 && cpf.isValid(d.cpf) && d.dataNasc != "" && d.grau != -1);
          }
          if (!c) {
            res = false;
          }
          break;

        //INFORMACOES DE ENDERECO
        case 2:
          res = false;
          if (this.$route.query.plano != "Essencial") {
            if (Array.isArray(this.$store.state.proposta.beneficiarios)) {
              for (let i = 0; i < this.$store.state.proposta.beneficiarios.length; i++) {
                res = (this.isValid(this.$store.state.proposta.beneficiarios[i].nome) &&
                  this.isValid(this.$store.state.proposta.beneficiarios[i].bairro) &&
                  this.isValid(this.$store.state.proposta.beneficiarios[i].cep) &&
                  this.isValid(this.$store.state.proposta.beneficiarios[i].logradouro) &&
                  this.isValid(this.$store.state.proposta.beneficiarios[i].uf) &&
                  this.isValid(this.$store.state.proposta.beneficiarios[i].numero) &&
                  cpf.isValid(this.$store.state.proposta.beneficiarios[i].cpf)
                )
              }
            } else {
              res = false;
            }
          }
          break;
        case 3:
          if (this.$store.state.proposta.verificado == true) {
            res = true;
          } else {
            res = false;
          }
          break;
      }

      return res;
    },

    isValid(str) {
      if (typeof str === 'undefined' || str === null || str == "") {
        return false;
      } else {
        return true;
      }
    },

    scrollTopAndVerify() {
      if (!this.canGoNext()) {
        this.$buefy.toast.open({
          duration: 5000,
          message: `Ainda existem campos obrigatórios não preenchidos!`,
          position: 'is-bottom',
          type: 'is-danger'
        })
      } else {
        this.activeStep = this.activeStep + 1
        window.scrollTo({
          top: 0,
          behavior: "smooth"
        });
      }
    },

    updateValue({ campo, valor }) {
      if (campo == "cpf") {
        this.getCPF(valor);
      }

      //@todo teste
      this.dadosForm[campo] = valor;
      this.$forceUpdate();
    },

    async callIdadeAlert(msg) {
      this.activeStep = this.activeStep - 1;
      await Swal.fire(
        'Aviso',
        msg,
        'error'
      )

      // this.$refs.perguntas.clearIdade();
    },

    async getCPF(valor) {
      if (valor.length > 10) {
        let formData = new FormData();

        formData.append('app', 'fcontrato');
        formData.append('cpf', valor);

        if (!cpf.isValid(valor)) {
          this.$buefy.toast.open({ type: "is-danger", message: "CPF inválido!" });
        } else {
          await this.$axios.post('https://www.floriculturaathia.com.br/pla/upload.php', formData, {

            headers: {
              'Content-Type': 'multipart/form-data',
              'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
              'User-Agent': 'My-App',
              'Accept': '*/*',
            }
          }).then((response) => this.updateCPFContrato(response));
        }
      } else {

      }
    },

    async updateCPFContrato(response) {

      if (response.data[0].POSSUI === "1") {

        await Swal.fire(
          'Aviso',
          'O CPF informado possui contrato ativo! Entre em contato com a central de atendimento para mais informações' +
          '<br> <strong>18 2101-5555</strong>',
          'error'
        )

        this.$refs.pessoa.clearCPF();

      }
      if (response.data[0].POSSUI === "PROCESSAMENTO") {

        await Swal.fire(
          'Aviso',
          'O CPF informado está com uma proposta em processamento! Entre em contato com a central de atendimento para mais informações' +
          '<br> <strong>18 2101-5555</strong>',
          'error'
        )
        this.$refs.pessoa.clearCPF();
      }
    }
  },

  async fetch() {
    this.mountains = await fetch(
      'https://api.nuxtjs.dev/mountains'
    ).then(res => res.json())
  },
  mounted() {
    this.currentVendedor = this.$route.query.vend;

    if (this.$route.query.vend) {
      this.possuiVendedor = true;
      //  console.log("CODIGO DO VENDEDOR");
      //  console.log(this.currentVendedor);

      var data = new FormData();

      data.append("func", "getvendedor");
      data.append("vend", this.currentVendedor);

      let body = { func: "getvendedor", vend: this.currentVendedor };

      // console.log(body);

      let response;
      call('', data, rs => {
        response = rs;

        this.vendedorNome = response.NOME_VENDEDOR;
      });
    }

    setTimeout(() => {
      this.activeStep = 0; this.visivel = true
    }, 100);
  },
}
</script>

<style>
.erro {
  border-color: red;
}
</style>

<style scoped></style>
