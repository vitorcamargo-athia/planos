<template>
  <div>
    <br>
    <article class="panel is-info">
      <p class="panel-heading">
        {{ parentesco }}
      </p>

      <div class="box">
        <b-field label="Nome*" :disabled="!incluir">
          <b-input v-model.lazy="valueFields.nomeD" :disabled="!incluir" :required="!valueFields.nomeD && incluir"
            @input.native="updateValue('nomeD', $event.target.value)"></b-input>
        </b-field>

        <b-field grouped group-multiline>
          <b-field label="CPF*">
            <the-mask class="input" :mask="['###.###.###-##']" v-model="valueFields.cpf"
              :required="!valueFields.nomeD && incluir" :disabled="!incluir"
              @input.native="updateValue('cpf', $event.target.value)" id="v-card-number"
              :class="{ 'erro': cpfInvalido }" />
          </b-field>
          <b-field label="Estado Civil">
            <b-select v-model="valueFields.estCivil" @change.native="updateValue('estCivil', $event.target.value)">
              <option value="1">Solteir{{ genero }}</option>
              <option value="2">Casad{{ genero }}</option>
              <option value="3">Viúv{{ genero }}</option>
              <option value="4">Divorciad{{ genero }}</option>
              <option value="7">União Estável</option>
              <option value="5">Outros</option>
            </b-select>
          </b-field>
          <b-field label="Data de nascimento*">
            <input type="date" class="input" v-model="valueFields.dataNasc" :required="!valueFields.dataNasc"
              @input="updateValue('dataNasc', $event.target.value)" id="v-card-number" />

          </b-field>
          <b-field label="Sexo">

            <b-radio v-model="valueFields.sexo" @change.native="updateValue('sexo', $event.target.value)"
              native-value="f">
              Feminino
            </b-radio>
            <b-radio v-model="valueFields.sexo" @change.native="updateValue('sexo', $event.target.value)"
              native-value="m">
              Masculino
            </b-radio>
            <!-- 
            <b-radio v-model="valueFields.sexo" @change.native="updateValue('sexo', $event.target.value)"
              native-value=" ">
              Prefiro não informar
            </b-radio> -->


          </b-field>

        </b-field>


        <b-field label="Cortesia?" v-if="parentesco == 'Dependente' && depCortesia > 0">

          <b-radio v-model="valueFields.cortesia"
            @change.native="$event => { setCortesia($event.target.value); updateValue('cortesia', $event.target.value) }"
            native-value="s">
            Sim
          </b-radio>
          <b-radio v-model="valueFields.cortesia"
            @change.native="$event => { setCortesia($event.target.value); updateValue('cortesia', $event.target.value) }"
            native-value="n">
            Não
          </b-radio>


        </b-field>

        <b-field label="Parentesco*">
          <div class="select is-fullwidth">
            <select :disabled="automatico" v-model="valueFields.grau" @change="updateValue('grau', $event.target.value)">
              <option v-for="( item, index ) in  this.grauParentesco " :value="item.COD" :key="index">{{ item.GRAU }}
              </option>
            </select>
          </div>
        </b-field>
        <h4 v-if="!(parentescoExtra ||
          valueFields.cortesia == 's'                      // E NÃO É CORTESIA
        )">
          Valor do extra: R$ {{ formatPrice(valorextra) }}
        </h4>
      </div>
    </article>

  </div>
</template>

<script>
import AnexoDoc from "./AnexoDoc";
import { TheMask } from "vue-the-mask";
import setProposta from "~/mixins/setProposta";
import { cpf } from "cpf-cnpj-validator";
import Dinheiro from "../mixins/Dinheiro";
import Url from '~/mixins/Url';

export default {
  name: "ExtraPessoa",
  mixins: [setProposta, Dinheiro, Url],
  mounted() {
    this.grauParentesco = this.getGrau();

    if (this.parentesco == "Pai") {
      this.valueFields.grau = 2;
      this.automatico = true;
    }
    if (this.parentesco == "Mãe") {
      this.valueFields.grau = 3;
      this.automatico = true;
    }

    if (this.parentesco == "Sogro") {
      this.valueFields.grau = 6;
      this.automatico = true;
    }

    if (this.parentesco == "Sogra") {
      this.valueFields.grau = 6;
      this.automatico = true;
    }

    if (this.parentesco == "Conjuge") {
      this.valueFields.grau = 10;
      this.automatico = true;
    }



  },
  computed: {
    parentescoExtra() {
      let out = false;
      switch (this.$route.query.plano) {
        case 'Adapt':
          out = this.valueFields.grau == 10 ||                             // E NÃO É CÔNJUGE
            (this.valueFields.grau == 5 && this.idade < 30 && this.valueFields.estCivil == 1);           // E NÃO É FILHO MENOR QUE 30 ANOS SOLTEIRO
          break;
        case 'Essencial':
        case 'Clássico':
        case 'Supremo':
          out = this.valueFields.grau == 10 ||                             // E NÃO É CÔNJUGE
            (this.valueFields.grau == 5 && this.idade < 35 && this.valueFields.estCivil == 1) || // E NÃO É FILHO MENOR QUE 30 ANOS SOLTEIRO
            this.valueFields.grau == 2 || this.valueFields.grau == 3 ||     // PAI E MÃE
            this.valueFields.grau == 6;     // SOGRO E SOGRA
      }

      return out;
    },
    genero() {
      return this.valueFields.sexo == 'f' ? 'a' : 'o';
    },
    idade() {
      function idade(ano_aniversario, mes_aniversario, dia_aniversario) {
        var d = new Date,
          ano_atual = d.getFullYear(),
          mes_atual = d.getMonth() + 1,
          dia_atual = d.getDate(),

          ano_aniversario = +ano_aniversario,
          mes_aniversario = +mes_aniversario,
          dia_aniversario = +dia_aniversario,

          quantos_anos = ano_atual - ano_aniversario;

        if (ano_atual - 999 > ano_aniversario)
          return 0;

        if (mes_atual < mes_aniversario || mes_atual == mes_aniversario && dia_atual < dia_aniversario) {
          quantos_anos--;
        }

        return quantos_anos < 0 ? 0 : quantos_anos;
      }

      let d = this.valueFields.dataNasc.split('-');

      return idade(d[0], d[1], d[2]);
    },
    valorextra() {
      let val = 0;
      if (!(this.parentescoExtra || this.valueFields.cortesia == 's'))
        for (let i = 0; i < this.$store.state.extras.length; i++) {
          if (this.idade >= this.$store.state.extras[i].IDADE_MIN && this.idade <= this.$store.state.extras[i].IDADE_MAX)
            val = this.$store.state.extras[i].VALOR;
        }
      return val;
    },
    cpfInvalido() {
      return !cpf.isValid(this.valueFields.cpf) && this.valueFields.cpf.length == 11;
    }
  },
  methods: {
    setCortesia(val) {
      this.$emit('change', val, () => this.valueFields.cortesia = 'n')
    },

    updateValue(campo, value) {
      this.updateDependente({
        'nome': this.valueFields.nomeD,
        'cpf': this.valueFields.cpf,
        'dataNasc': this.valueFields.dataNasc,
        'grau': this.valueFields.grau,
        'sexo': this.valueFields.sexo,
        'cortesia': this.valueFields.cortesia,
        'estCivil': this.valueFields.estCivil,
        'valor': this.valorextra == 0 ? 0 : Number(this.valorextra.replace(",", "."))
      }, this.indice);
      this.$emit("change", {
        campo: {
          'nome': this.valueFields.nomeD,
          'cpf': this.valueFields.cpf,
          'dataNasc': this.valueFields.dataNasc,
          'grau': this.valueFields.grau,
          'sexo': this.valueFields.sexo,
          'cortesia': this.valueFields.cortesia,
          'estCivil': this.valueFields.estCivil,
          'valor': this.valorextra == 0 ? 0 : Number(this.valorextra.replace(",", "."))
        },
        valor: value,
      });
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
    }
  },

  data: () => ({

    incluir: true,

    grauParentesco: [],

    automatico: false,

    valueFields: {
      nomeD: "",
      cpf: "",
      dataNasc: "",
      grau: -1,
      sexo: '',
      cortesia: 'n',
      estCivil: 1
    },
    crematorio: false
  }),
  props: ["parentesco",
    "indice", 'depCortesia'
  ],

  components: { AnexoDoc, TheMask }
}
</script>


