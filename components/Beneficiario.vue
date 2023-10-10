<template>
  <div>
    <div class="card">
      <h1 class="title has-text-centered">Informações do beneficiário</h1>
      <div class="card-content">

        <article class="panel is-info">
          <p class="panel-heading">
            Beneficiário do seguro de vida
          </p>

          <div class="box">

            <b-field grouped group-multiline>
              <b-field label="Nome *" :disabled="!incluir" expanded>
                <b-input v-model="valueFields.nomeD" :disabled="!incluir" :required="!valueFields.nomeD && incluir"
                  @input.native="updateValue('nomeD', $event.target.value)"></b-input>
              </b-field>


              <b-field label="CPF *" expanded>
                <the-mask class="input" :mask="['###.###.###-##']" v-model="valueFields.cpf"
                  :required="!valueFields.nomeD && incluir" :disabled="!incluir" :class="{ 'erro': cpfInvalido }"
                  @input.native="updateValue('cpf', $event.target.value)" id="v-card-number" />

              </b-field>

              <b-field label="Sexo*">

                <b-radio v-model="valueFields.sexo" @input.native="updateValue('sexo', $event.target.value)"
                  native-value="f">
                  Feminino
                </b-radio>
                <b-radio v-model="valueFields.sexo" @input.native="updateValue('sexo', $event.target.value)"
                  native-value="m">
                  Masculino
                </b-radio>
                <!-- <b-radio v-model="valueFields.sexo" @input.native="updateValue('sexo', $event.target.value)"
                    native-value=" ">
                    Prefiro não informar
                  </b-radio> -->
              </b-field>
            </b-field>

            <b-field grouped group-multiline>
              <b-field label="Data de nascimento *">
                <input type="date" class="input" v-model="valueFields.dataNasc" :required="!valueFields.dataNasc"
                  @input="updateValue('dataNasc', $event.target.value)" id="v-card-number" />

              </b-field>

              <b-field label="Parentesco *" expanded>
                <div class="select is-fullwidth">
                  <select v-model="valueFields.grau" @click="updateValue('grau', $event.target.value)">
                    <option v-for="(item, k) in this.grauParentesco" :value="item.COD" :key="k">{{ item.GRAU }}</option>
                  </select>
                </div>
              </b-field>


              <b-field label="Celular">
                <the-mask class="input" :mask="['(##) #####-####']" v-model="valueFields.celular"
                  :required="!valueFields.celular" id="v-card-number" @input="updateValue('celular', $event)" />
              </b-field>
            </b-field>

            <!--BEGIN ENDEREÇO-->
            <br />
            <article class="panel is-info">
              <p class="panel-heading">
                Endereço
              </p>
              <div class="box">
                <b-field label="CEP *" grouped>
                  <p class="control">
                    <the-mask class="input" v-model="valueFields.cep" :required="!cep" :mask="'#####-###'" type="text"
                      @input.native="updateValue('cep', cep)" />
                  </p>
                  <p class="control">
                    <b-button class="button" @click="preencheEndereco()">Buscar</b-button>
                  </p>
                </b-field>

                <b-field grouped group-multiline>
                  <b-field label="Endereço *" expanded>
                    <input class="input" :disabled="getLogradouro" v-model.lazy="valueFields.logradouro" type="text"
                      :required="!logradouro" @input="updateValue('logradouro', $event.target.value)" />
                  </b-field>
                  <b-field label="Número *">
                    <input class="input" v-model.lazy="valueFields.numero" type="text" required
                      @input="updateValue('numero', $event.target.value)" />
                  </b-field>
                  <b-field label="Complemento" expanded>
                    <input class="input" v-model.lazy="valueFields.complemento" type="text"
                      @input="updateValue('complemento', $event.target.value)" />
                  </b-field>
                </b-field>

                <b-field grouped group-multiline>
                  <b-field label="Bairro *" expanded>
                    <input class="input" v-model.lazy="valueFields.bairro" :disabled="getBairro" type="text" required
                      @input="updateValue('bairro', $event.target.value)" />
                  </b-field>
                  <b-field label="Cidade *" expanded>
                    <input class="input" v-model.lazy="valueFields.cidade" :disabled="getCidade" type="text" required
                      @input="updateValue('cidade', $event.target.value)" />
                  </b-field>
                  <b-field label="Estado *">
                    <div class="select is-fullwidth">
                      <select v-model="valueFields.uf" :disabled="getEstado"
                        @input="updateValue('uf', $event.target.value)">
                        <option value="AC">Acre</option>
                        <option value="AL">Alagoas</option>
                        <option value="AP">Amapá</option>
                        <option value="AM">Amazonas</option>
                        <option value="BA">Bahia</option>
                        <option value="CE">Ceará</option>
                        <option value="DF">Distrito Federal</option>
                        <option value="ES">Espírito Santo</option>
                        <option value="GO">Goiás</option>
                        <option value="MA">Maranhão</option>
                        <option value="MT">Mato Grosso</option>
                        <option value="MS">Mato Grosso do Sul</option>
                        <option value="MG">Minas Gerais</option>
                        <option value="PA">Pará</option>
                        <option value="PB">Paraíba</option>
                        <option value="PR">Paraná</option>
                        <option value="PE">Pernambuco</option>
                        <option value="PI">Piauí</option>
                        <option value="RJ">Rio de Janeiro</option>
                        <option value="RN">Rio Grande do Norte</option>
                        <option value="RS">Rio Grande do Sul</option>
                        <option value="RO">Rondônia</option>
                        <option value="RR">Roraima</option>
                        <option value="SC">Santa Catarina</option>
                        <option value="SP">São Paulo</option>
                        <option value="SE">Sergipe</option>
                        <option value="TO">Tocantins</option>
                      </select>
                    </div>
                  </b-field>
                </b-field>
              </div>
            </article>


          </div>
        </article>
        <!--END ENDEREÇO-->
      </div>
    </div>
  </div>
</template>
<script>
import AnexoDoc from "./AnexoDoc";
import { TheMask } from "vue-the-mask";
import setProposta from "~/mixins/setProposta";
import { cpf } from "cpf-cnpj-validator";

export default {
  name: "Beneficiario",
  mixins: [setProposta],
  mounted() {
    this.grauParentesco = this.getGrau();
    if (this.endereco) {
      this.cep = this.endereco.cep;
      this.logradouro = this.endereco.logradouro;
      this.numero = this.endereco.numero;
      this.complemento = this.endereco.complemento;
      this.bairro = this.endereco.bairro;
      this.cidade = this.endereco.cidade;
      this.uf = this.endereco.uf;
    }
  },
  computed: {
    cpfInvalido() {
      return !cpf.isValid(this.valueFields.cpf) && this.valueFields.cpf.length == 11;
    }
  },
  methods: {
    updateValue(campo, value) {


      if (campo == "dataNasc") {

        let dataAtual = new Date().getFullYear();

        let current = new Date(value).getFullYear();

        if (current > dataAtual) {
          this.valueFields.dataNasc = new Date();
        }

      }

      this.updateBeneficiario({
        'nome': this.valueFields.nomeD, 'cpf': this.valueFields.cpf,
        'dataNasc': this.valueFields.dataNasc, 'grau': this.valueFields.grau,
        'sexo': this.valueFields.sexo,
        'cep': this.valueFields.cep,
        'logradouro': this.valueFields.logradouro,
        'numero': this.valueFields.numero,
        'complemento': this.valueFields.complemento,
        'bairro': this.valueFields.bairro,
        'uf': this.valueFields.uf,
        'celular': this.valueFields.celular,
        'cidade': this.valueFields.cidade,

      }, 0); //inicial 0; investigar problema de auto increment ao digitar
      this.$emit("change", {
        campo: {
          'nome': this.valueFields.nomeD, 'cpf': this.valueFields.cpf, 'dataNasc': this.valueFields.dataNasc,
          'grau': this.valueFields.grau, 'sexo': this.valueFields.sexo,
          'cep': this.valueFields.cep,
          'logradouro': this.valueFields.logradouro,
          'numero': this.valueFields.numero,
          'complemento': this.valueFields.complemento,
          'bairro': this.valueFields.bairro,
          'uf': this.valueFields.uf,
          'celular': this.valueFields.celular,
          'cidade': this.valueFields.cidade,
        },
        valor: value,
      });
      this.$emit('atualiza');
    },

    async getGrau() {

      let formData = new FormData();

      formData.append('app', 'getgrau');

      await this.$axios.post(this.url, formData, {

        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      }).then((response) => this.updateGrau(response));
    },

    updateGrau(response) {
      this.grauParentesco = response.data;
    },
    preencheEndereco() {
      fetch("https://viacep.com.br/ws/" + this.valueFields.cep + "/json/")
        .then((res) => res.json())
        .then((res) => {

          if (res.logradouro) {
            this.valueFields.logradouro = res.logradouro;
            this.updateValue("logradouro", this.valueFields.logradouro);
            this.getLogradouro = true;
          }

          if (res.bairro) {
            this.valueFields.bairro = res.bairro;
            this.updateValue("bairro", this.valueFields.logradouro);
            this.getBairro = true;
          }

          if (res.localidade) {
            this.valueFields.cidade = res.localidade;
            this.updateValue("cidade", this.valueFields.cidade);
            this.getCidade = true;
          }

          if (res.uf) {
            this.valueFields.uf = res.uf;
            this.updateValue("uf", this.valueFields.uf);
            this.getEstado = true;
          }
        });
    }
  },

  data: () => ({

    incluir: true,

    grauParentesco: [],
    getLogradouro: false,
    getBairro: false,
    getCidade: false,
    getEstado: false,

    valueFields: {
      nomeD: "",
      cpf: "",
      dataNasc: "",
      grau: -1,
      sexo: '',
      cep: "",
      logradouro: "",
      numero: "",
      complemento: "",
      bairro: "",
      cidade: "",
      uf: "",

    },
    crematorio: false
  }),
  props: ["parentesco",
    "endereco",
    "indice"
  ],

  components: { AnexoDoc, TheMask }
}
</script>
