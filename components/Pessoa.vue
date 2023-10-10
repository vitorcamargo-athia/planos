<template>
  <div class="card" ref="pessoa">
    <h1 class="title has-text-centered">Informações Pessoais</h1>
    <div class="card-content">
      <div class="content">
        <article class="panel is-info">
          <p class="panel-heading">
            Titular
          </p>

          <div class="box">
            <b-field grouped group-multiline>
              <b-field label="Nome*" expanded>
                <b-input v-model="valueFields.nome" :required="!valueFields.nome"
                  @input.native="updateValue('nome', $event.target.value)"></b-input>
              </b-field>
              <b-field label="Email*" expanded>
                <b-input type="email" v-model="valueFields.email" :required="!valueFields.email"
                  @input.native="updateValue('email', $event.target.value)"></b-input>
              </b-field>

              <b-field label="Celular*">
                <the-mask class="input" :mask="['(##) #####-####']" v-model="valueFields.celular"
                  :required="!valueFields.celular" id="v-card-number" @input="updateValue('celular', $event)" />
              </b-field>
            </b-field>

            <b-field grouped group-multiline>
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
                <input type="date" class="input" @blur="validaData" v-model="valueFields.dataNasc"
                  :required="!valueFields.dataNasc" @input="updateValue('dataNasc', $event.target.value)" id="dtNasc" />
              </b-field>
              <b-field label="CPF*" expanded>
                <the-mask class="input" :mask="['###.###.###-##']" v-model="valueFields.cpf" :required="!valueFields.cpf"
                  @input="updateValue('cpf', $event)" id="v-card-number" />
              </b-field>

              <b-field label="RG*">
                <b-input value="" maxlength="25" :required="!valueFields.rg" @input="updateValue('rg', $event)"></b-input>
              </b-field>
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

          </div>
        </article>

        <TitEndereco />

        <template v-if="depCortesia > 0">
          Direito a {{ depCortesia }} dependente{{ depCortesia > 1 ? 's' : '' }}-cortesia
        </template>

        <ExtraPessoa parentesco="Conjuge" v-if="this.$store.state.proposta.conjuge" :indice="indices.conjuge"
          :depCortesia="depCortesia" @change="checkCortesia" />

        <ExtraPessoa parentesco="Pai" v-if="this.$store.state.proposta.dpai" :indice="indices.dpai"
          :depCortesia="depCortesia" @change="checkCortesia" />
        <ExtraPessoa parentesco="Mãe" v-if="this.$store.state.proposta.dmae" :indice="indices.dmae"
          :depCortesia="depCortesia" @change="checkCortesia" />

        <ExtraPessoa parentesco="Sogro" v-if="this.$store.state.proposta.dsogro" :indice="indices.dsogro"
          :depCortesia="depCortesia" @change="checkCortesia" />
        <ExtraPessoa parentesco="Sogra" v-if="this.$store.state.proposta.dsogra" :indice="indices.dsogra"
          :depCortesia="depCortesia" @change="checkCortesia" />

        <ExtraPessoa v-for="(x, index) in filhos" :key="index" parentesco="Dependente" :indice="index + indices.outros"
          :depCortesia="depCortesia" @change="checkCortesia" />

      </div>
      <AnexoDoc />
    </div>
  </div>
</template>

<script>
import setProposta from "~/mixins/setProposta";
import { TheMask } from "vue-the-mask";

import ExtraPessoa from "./ExtraPessoa";
import AnexoDoc from "./AnexoDoc";
import Swal from "sweetalert2";


export default {

  name: "Pessoa",
  mixins: [setProposta],
  computed: {
    genero() {
      return this.valueFields.sexo == 'f' ? 'a' : 'o';
    },
    depCortesia() {
      let d = 0;
      switch (this.$route.query.plano) {
        case 'Clássico': d = 1; break;
        case 'Supremo': d = 2; break;
      }

      return d;
    }
  },
  methods: {
    checkCortesia(val, cb) {
      if (val == 's') {
        if (this.cortesias < this.depCortesia) {
          this.cortesias++;
        } else {
          Swal.fire('Alerta', 'Direito a ' + this.depCortesia + ' dependente' + (this.depCortesia > 1 ? 's' : '') + '-cortesia', 'warning')
          cb();
        }
      } else if (val == 'n') {
        this.cortesias--;
      }
    },

    getDependentes() {

    },

    validaData() {

      let sDataNasc = new Date(this.valueFields.dataNasc);

      if (sDataNasc.getTime() > this.maxDate.getTime()) {
        this.valueFields.dataNasc = null;
      }
    },

    clearCPF() {
      this.valueFields.cpf = '';
      this.updateValue('cpf', '')
    },
    updateValue(campo, valor, index = -1) {

      if (campo == "dataNasc") {

        let dataAtual = new Date().getFullYear();

        let current = new Date(valor).getFullYear();

        if (current > dataAtual) {
          this.valueFields.dataNasc = new Date();
        }

      }

      if (index != -1) {

        // console.log(index);
      }
      this.update(campo, valor);

      this.$emit("change", {
        campo: campo,
        valor: valor,
      });
    }
  }, props: [
    "filhos",
    "conjuge",
    'indices'
  ],
  data() {

    const today = new Date()


    return {

      cortesias: 0,

      date: new Date(),
      minDate: new Date(today.getFullYear() - 80, today.getMonth(), today.getDate()),
      maxDate: today,
      valueFields: {
        nome: "",
        email: "",
        celular: "",
        dataNasc: "",
        cpf: "",
        rg: "",
        sexo: "",
        dependentes: [],
        pai: {
          nomeD: "",
          cpf: "",
          dataNasc: "",

        },
        estCivil: 1
      }
    }
  },
  mounted() {



    this.dependentes = [].fill({ nomeD: '', cpf: '', dataNasc: '' }, 0, this.filhos + 5);
    document.getElementById("dtNasc").setAttribute('max', (this.maxDate.getFullYear() + "-" + (this.maxDate.getMonth() + 1 + '').padStart(2, '0') + "-" + (this.maxDate.getDate() + '').padStart(2, '0')));

  },
  watch: {

  },
  components: { AnexoDoc, ExtraPessoa, TheMask }
}
</script>
<style scoped></style>
