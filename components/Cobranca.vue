<template>
  <div>

    <div class="card">
      <h1 class="title has-text-centered">Método de Cobrança</h1>
      <div class="card-content">
        <div class="content">

          <article class="panel is-info">
            <p class="panel-heading">
              Termos
            </p>

            <div class="box">
              <b-field>
                <input type="checkbox" v-model="condicoesGerais" @change="update('concorda1', $event.target.checked)">
                &nbsp;Concordo com as <a @click="isCardModalActive = true">&nbsp; condições gerais</a>
              </b-field>

              <b-field>
                <input type="checkbox" v-model="politica" @change="update('concorda2', $event.target.checked)">
                &nbsp;Concordo com a <a @click="isPoliticaModalActive = true">&nbsp;política de privacidade</a>
              </b-field>

              <Token :telefone="telefone"
                v-if="$store.state.proposta.concorda2 && $store.state.proposta.concorda1 && !$route.query.vend" />

            </div>
          </article>

          <b-modal v-model="isCardModalActive" :width="640" scroll="keep">
            <div class="card">
              <div class="card-image">
              </div>
              <div class="card-content">
                <div class="content">
                  <iframe src="https://www.floriculturaathia.com.br/pla/termos.pdf" title="Termos" :width="600"
                    :height="650"></iframe>
                </div>
              </div>
            </div>
          </b-modal>

          <b-modal v-model="isPoliticaModalActive" :width="640" scroll="keep">
            <div class="card">
              <div class="card-image">
              </div>
              <div class="card-content">
                <div class="content">
                  <iframe src="https://www.floriculturaathia.com.br/pla/politica.pdf" title="Política de privacidade"
                    :width="600" :height="650"></iframe>
                </div>
              </div>
            </div>
          </b-modal>
          <br>
          <div class="columns columns is-centered">
            <div class="column is-full">

              <br>


              <br>

              <div
                v-if="(this.$store.state.proposta.verificado && !$route.query.vend) || ($store.state.proposta.concorda2 && $store.state.proposta.concorda1 && $route.query.vend)">

                <article class="panel is-info">
                  <p class="panel-heading">
                    Forma de pagamento
                  </p>

                  <div class="panel">
                    <div class="box">
                      <h6 class="title is-4">Plano: {{ this.$route.query.plano }}</h6>
                      <h6 class="title is-4 has-text-primary">Resumo dos valores mensais</h6>
                      <table class="table is-striped is-narrow">
                        <thead>
                          <tr>
                            <th>Descrição</th>
                            <th>Valor</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr>
                            <td>Mensalidade</td>
                            <td>R$ {{ formatPrice(valorSubtotalMensalidade) }}</td>
                          </tr>
                          <tr>
                            <td>Extras</td>
                            <td>R$ {{ formatPrice(valorSubtotalExtra) }}</td>
                          </tr>
                          <tr>
                            <td>Cremação</td>
                            <td>R$ {{ formatPrice(valorSubtotalCremacao) }}</td>
                          </tr>
                          <tr>
                            <td>Total</td>
                            <td><strong>R$ {{ formatPrice(valorSubtotalMensalidade + valorSubtotalExtra +
                              valorSubtotalCremacao)
                            }}</strong></td>
                          </tr>
                        </tbody>
                      </table>

                      <!-- <h6 class="title is-4 has-text-primary" v-if="this.$store.state.proposta.crematorio == 's'">Total: R$ {{this.total}}</h6> !-->


                      <h5 class="title is-5">Forma de pagamento da mensalidade</h5>
                      <b-radio size="is-medium" v-model="plano" name="cobranca"
                        @input.native="updateValue('mcobranca', $event.target.value)" native-value="0">

                        Cartão de crédito (Crédito recorrente)
                      </b-radio>

                      <b-radio size="is-medium" v-model="plano" name="cobranca"
                        @input.native="updateValue('mcobranca', $event.target.value)" native-value="1">
                        Carnê
                      </b-radio>

                      <b-radio size="is-medium" v-model="plano" name="cobranca"
                        @input.native="updateValue('mcobranca', $event.target.value)" native-value="2">
                        Carnê digital
                      </b-radio>

                      <h5 class="title is-4">Dia do vencimento</h5>
                      <b-radio size="is-medium" v-model="vencto" name="vencto"
                        @input.native="updateValue('vencto', $event.target.value)" native-value="10">

                        Dia 10
                      </b-radio>

                      <b-radio size="is-medium" v-model="vencto" name="vencto"
                        @input.native="updateValue('vencto', $event.target.value)" native-value="20">
                        Dia 20
                      </b-radio>

                      <b-radio size="is-medium" v-model="vencto" name="vencto"
                        @input.native="updateValue('vencto', $event.target.value)" native-value="30">
                        Dia 30
                      </b-radio>

                      <h5 class="title is-4" v-if="this.$store.state.proposta.verificado && !$route.query.vend">Forma de
                        pagamento da adesão</h5>

                      <b-radio size="is-medium" v-model="pagtonow" name="pagtonow" native-value="0"
                        v-if="this.$store.state.proposta.verificado && !$route.query.vend">
                        Cartão de crédito
                      </b-radio>

                      <h6 class="title is-4 has-text-primary">Valor da adesão: R$ {{ formatPrice(this.entrada) }}</h6>

                    </div>
                  </div>

                </article>

                <div
                  v-if="(this.$store.state.proposta.verificado && !$route.query.vend) || ($store.state.proposta.concorda2 && $store.state.proposta.concorda1 && $route.query.vend)">

                  <article class="panel is-info" v-if="(this.$store.state.proposta.verificado && !$route.query.vend)">
                    <p class="panel-heading">
                      Pagamento da adesão
                    </p>

                    <div class="panel">

                      <div class="box">
                        <h6 class="title is-4">Valor da adesão: R$ {{ formatPrice(this.entrada) }}</h6>
                        <Cartao card="Cartão de Crédito" v-if="pagtonow == 0" @change="updateCartao" :dados="cartao"
                          hide_tipo="true" />
                        <Pix v-else></Pix>
                      </div>
                    </div>
                  </article>

                  <button class="button is-primary" @click="efetuaPagto" :disabled="pagConcluido"
                    v-if="this.$store.state.proposta.verificado">Finalizar proposta</button>

                  <button class="button is-primary" @click="criaProposta" :disabled="pagConcluido"
                    v-if="$route.query.vend">Finalizar proposta</button>
                </div>

                <br>
              </div>



            </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import Cartao from "./Cartao";
import Debito from "./Debito";
import setProposta from "@/mixins/setProposta";
import Url from "~/mixins/Url";
import Dinheiro from "../mixins/Dinheiro";
import Swal from "sweetalert2";
import criaProposta from "~/mixins/criaProposta";

export default {

  mixins: [setProposta, Dinheiro, Url, criaProposta],

  async mounted() {
    await this.atualizaValores();
  },

  created() {
    this.atualizaValores();
  },


  async updated() {

  },



  name: "Cobranca",
  components: { Debito, Cartao },

  data() {
    return {
      cartao: {
        num_cartao: "",
        bandeira: "",
        nome_cartao: "",
        validade_mes: "",
        validade_ano: "",
        cvv: "",
        tipo: "",
      },
      cartao2: {
        num_cartao: "",
        bandeira: "",
        nome_cartao: "",
        validade_mes: "",
        validade_ano: "",
        cvv: "",
        tipo: "",
      },

      pagtonow: 0,
      plano: '',
      vencto: 10,
      valor: 0,
      cremac: 20,
      entrada: 0,
      codigoValido: false,
      isCardModalActive: false,
      isPoliticaModalActive: false,
      condicoesGerais: false,
      politica: false,
      validado: false,
      pagConcluido: false,
      codplano: 16
    }
  },
  methods: {
    async criaProposta() {

      await this.createProposta();

      this.$router.push('/finalizacao?vend=' + this.$route.query.vend + "&cod_proposta=" + this.codigo);
    },

    updateCartao({ campo, valor }) {

      this.update(campo, valor);
      this.atualizaValores();

      this.cartao[campo] = valor;
    },
    updateValue(campo, value) {

      this.update(campo, value);
      this.atualizaValores();

      this.$emit("change", {
        campo: campo,
        valor: value,
      });
    },

    updateMensalidades(value) {

      this.updateMensal(value);
    },

    async atualizaValores() {
      //OBTEM PLANO
      if (this.$route.query.plano == 'Adapt') {
        this.codplano = 17
      }
      if (this.$route.query.plano == 'Essencial') {
        this.codplano = 13
      }
      if (this.$route.query.plano == 'Clássico') {
        this.codplano = 14
      }
      if (this.$route.query.plano == 'Supremo') {
        this.codplano = 15
      }

      this.getValorEntrada();
      this.getMensalidade();
    },

    validarCode() {

      this.state.validado = true;
    },
    finalizaForm() {

      Swal.fire({
        title: 'Deseja finalizar a proposta?',
        showDenyButton: true,
        showCancelButton: true,
        confirmButtonText: 'Sim',
        denyButtonText: 'Não',
        customClass: {
          actions: 'my-actions',
          cancelButton: 'order-1 right-gap',
          confirmButton: 'order-2',
          denyButton: 'order-3',
        }
      }).then((result) => {
        if (result.isConfirmed) {


          Swal.fire('Proposta finalizada com sucesso!', '', 'success')

          this.$router.push('/') //COMENTADO PARA EVITAR REDIGITAR O FORM

        } else if (result.isDenied) {
          Swal.fire('A proposta não foi finalizada.', '', 'info')
        }
      })
    },

    async efetuaPagto() {

      let strcard = 'Cartão: ' + this.$store.state.proposta.num_cartao + ' Bandeira: ' + this.$store.state.proposta.bandeira
        + ' Nome do titular: ' + this.$store.state.proposta.nome_cartao + ' CPF DO TIT: ' + this.$store.state.proposta.cpf_titular
        + ' Validade: ' + this.$store.state.proposta.validade_ano;

      //ENVIA PDFs da proposta por email

      let pformData = new FormData();

      let responseValue;

      //PASSAR POR PARAMETRO O CARTAO

      pformData.append("app", "pagamento");
      pformData.append("cpf", this.$store.state.proposta.cpf);
      pformData.append("cartao", JSON.stringify(this.cartao));

      pformData.append("valor", this.entrada);

      await this.$axios.post(this.url, pformData, {

        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      }).then((response) => responseValue = response.data);

      //Atualiza proposta, metodo de cobranca mcobranca

      this.updatePropostaMetodo();

      if (responseValue.success == true) {

        //Swal.fire('Pagamento aprovado!', '', 'success')
        this.enviaSMSPuro("Athia Planos: Estamos quase la, o seu pagamento esta sendo processado e em breve entraremos em contato")
        this.pagConcluido = true;
      } else {
        this.pagConcluido = false;
        this.enviaSMSPuro("Athia Planos: Estamos quase la, o seu pagamento esta sendo processado e em breve entraremos em contato")
        // Swal.fire('Pagamento em processamento.', responseValue.obj, 'info')
      }



      /*let pmformData = new FormData();

      pmformData.append("app", "mail");
      pmformData.append("email", this.$store.state.proposta.email);
      pmformData.append("nome", this.$store.state.proposta.nome);
      pmformData.append("cod", 0); //CODIGO DA PROPOSTA; PASSANDO 0 PORQUE NÃO VAI USAR MAIS
      pmformData.append("tipo", 0); //0 = INDIVIDUAL; 1 = ESSENCIAL; 2 = CLASSICO; 3 = SUPREMO



      await this.$axios.post('https://portal.athia.com.br/app/pmail.php', pmformData, {

        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });*/


      this.$router.push('/finalizacao');

    },

    async updatePropostaMetodo() {

      //APROVEITA E JÁ ATUALIZA A DATA DE COBR

      let fform = new FormData();

      let rest;

      fform.append("app", "updateproposta");
      fform.append("cpf", this.$store.state.proposta.cpf);
      fform.append("metodo", this.$store.state.proposta.mcobranca);

      fform.append("vencto", this.$store.state.proposta.vencto);


      await this.$axios.post(this.url, fform, {
        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      }).then((response) => rest = response.data); // Só para acompanhar

    },

    async getValorEntrada() {
      //OBTER A ENTRADA DO PLANO

      let pform = new FormData();

      pform.append("app", "getvalorplano");
      pform.append("cod", this.codplano);

      await this.$axios.post(this.url, pform, {
        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      }).then((response) => this.entrada = response.data);
    },

    async getMensalidade() {
      let pform = new FormData();

      pform.append("app", "getmensalidade");
      pform.append("cod", this.codplano);

      await this.$axios.post(this.url, pform, {
        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      }).then((response) => this.valor = response.data);

      if (typeof this.valor == 'number')
        this.valor = this.formatPrice(this.valor);
      this.updateMensalidades(this.valor)

    },


    async enviaSMSPuro(msg) {
      //==============ENVIAR SMS PURO; DESENVOLVIMENTO SOMENTE
      let formSms = new FormData();

      formSms.append("app", "enviasms");
      formSms.append("celular", this.$store.state.proposta.celular);
      formSms.append("mensagem", msg);

      await this.$axios.post('https://portal.athia.com.br/sms/sms_proposta.php', formSms, {

        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      });

      //======================================================
    }
  },

  props: [
    'telefone',
    'valorSubtotalMensalidade',
    'valorSubtotalExtra',
    'valorSubtotalCremacao'
  ]
}
</script>

<style scoped></style>
