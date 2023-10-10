<template>
  <div>
    <h1 class="title has-text-centered">Questionário</h1>

    <div class="card">
      <div class="card-content">
        <div class="content">

          <article class="panel is-info">
            <p class="panel-heading">
              Você tem mais de 70 anos de idade?
            </p>
            <div class="box">
              <div class="panel-block">
                <b-radio class="" v-model="maiorIdade" @input.native="updateValue('maiorIdade', $event.target.value)"
                  native-value="s">
                  Sim
                </b-radio>
                <b-radio v-model="maiorIdade" @input.native="updateValue('maiorIdade', $event.target.value)"
                  native-value="n">
                  Não
                </b-radio>
              </div>
            </div>

            <template v-if="$store.state.mensalidades">
              <div class="panel-block">
                <h4 class="title is-6">Valor da mensalidade de acordo com a idade do titular:</h4>
              </div>

              <div class="panel-block">
                <table class="table is-striped is-narrow">
                  <thead>
                    <tr>
                      <th>Idade do titular</th>
                      <th>Valor da mensalidade</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(val, index) in $store.state.mensalidades" :key="index">
                      <td v-if="val.IDADE_MIN == 0 && val.IDADE_MAX == 999">Qualquer idade</td>
                      <td v-else-if="val.IDADE_MIN == 0 && val.IDADE_MAX != 999">Até {{ val.IDADE_MAX }} anos</td>
                      <td v-else-if="val.IDADE_MAX != 999 && val.IDADE_MIN == 0">Entre {{ val.IDADE_MIN }} e {{
                        val.IDADE_MAX == 65 ? '70' : val.IDADE_MAX }} anos</td>
                      <td v-else-if="val.IDADE_MAX != 999">Entre {{ val.IDADE_MIN }} e {{ val.IDADE_MAX == 65 ? '70' :
                        val.IDADE_MAX }} anos</td>

                      <td v-if="val.IDADE_MAX != 999 || (val.IDADE_MAX == 999 && val.IDADE_MIN == 0)">R$ {{
                        formatPrice(val.VALOR) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </template>
          </article>

          <article class="panel is-info">
            <p class="panel-heading">
              Gostaria de adicionar cremação?
            </p>
            <div class="box">
              <div class="panel-block">
                <b-radio v-model="crematorio" @input.native="updateValue('crematorio', $event.target.value)"
                  native-value="s">
                  Sim
                </b-radio>
                <b-radio v-model="crematorio" @input.native="updateValue('crematorio', $event.target.value)"
                  native-value="n">
                  Não
                </b-radio>
                <div class="panel-block" v-if="crematorio == 's'">
                  <h4 class="title is-6">Cremação possui taxa adicional. (Valor de R$ {{ valCremacao }})</h4>
                </div>
              </div>
            </div>
          </article>

          <section>

            <article class="panel is-info">
              <p class="panel-heading">
                Possui cônjuge?
              </p>
              <div class="box">
                <div class="panel-block">
                  <b-radio v-model="conjuge"
                    @input.native="updateValue('conjuge', $event.target.value); atualizaIndices()" native-value="true">
                    Sim
                  </b-radio>
                  <b-radio v-model="conjuge"
                    @input.native="updateValue('conjuge', $event.target.value); atualizaIndices()" native-value="false">
                    Não
                  </b-radio>
                </div>
              </div>
            </article>

            <article class="panel is-info">
              <p class="panel-heading" v-if="conjuge && conjuge != 'false'">
                Gostaria de adicionar pai, mãe, sogro e sogra como dependente do plano?
              </p>
              <p class="panel-heading" v-else>
                Gostaria de adicionar pai e mãe como dependente do plano?
              </p>
              <div class="box">

                <div class="panel-block">
                  <b-field>
                    <b-checkbox v-model="dpai"
                      @input.native="updateValue('dpai', !dpai); atualizaIndices()">Pai</b-checkbox>
                    <b-checkbox v-model="dmae"
                      @input.native="updateValue('dmae', !dmae); atualizaIndices()">Mãe</b-checkbox>
                    <b-checkbox v-if="conjuge && conjuge != 'false'" v-model="dsogro"
                      @input.native="updateValue('dsogro', !dsogro); atualizaIndices()">Sogro</b-checkbox>
                    <b-checkbox v-if="conjuge && conjuge != 'false'" v-model="dsogra"
                      @input.native="updateValue('dsogra', !dsogra); atualizaIndices()">Sogra</b-checkbox>
                  </b-field>
                </div>
                <div class="panel-block">

                  <b-field label="Outros dependentes">

                    <b-numberinput v-model="filhos" :editable="false" :min="0" :max="20"
                      @input="updateValue('filhos', $event); atualizaIndices()"></b-numberinput>
                  </b-field>

                </div>
                <template v-if="(typeof valAdicional == 'number')">
                  <div class="panel-block">
                    <h4 class="title is-6">Filhos maiores de 35 anos possuirão cobrança adicional. (Valor de R$
                      {{ formatPrice(valAdicional) }})</h4>
                  </div>

                  <div class="panel-block">
                    <h4 class="title is-6">Demais graus de parentesco são adicionais. (Valor de R$ {{
                      formatPrice(valAdicional) }})
                    </h4>
                  </div>
                </template>
                <template v-else>
                  <div class="panel-block">
                    <h4 class="title is-6">Cônjuge e filhos solteiros até {{ $route.query.plano != 'Adapt' ? '35' : '30'
                    }}
                      são isentos de pagamento. Demais, seguem a
                      tabela abaixo:</h4>
                  </div>

                  <div class="panel-block">
                    <table class="table is-striped is-narrow">
                      <thead>
                        <tr>
                          <th>Idade</th>
                          <th>Valor</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="(val, index) in valAdicional" :key="index">
                          <td v-if="val.IDADE_MIN == 0 && val.IDADE_MAX == 999">Qualquer idade</td>
                          <td v-else-if="val.IDADE_MIN == 0">Até {{ val.IDADE_MAX }} anos</td>
                          <td v-else-if="val.IDADE_MAX == 999">A partir de {{ val.IDADE_MIN }} anos</td>
                          <td v-else>Entre {{ val.IDADE_MIN }} e {{ val.IDADE_MAX }} anos</td>
                          <td>R$ {{ formatPrice(val.VALOR) }}</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </template>
              </div>
            </article>

          </section>
        </div>

      </div>
    </div>
  </div>
</template>
<script>

import setProposta from "@/mixins/setProposta";
import Dinheiro from "../mixins/Dinheiro";
import Url from "~/mixins/Url";

export default {
  mixins: [setProposta, Dinheiro, Url],
  name: "Perguntas",
  methods: {

    atualizaIndices() {
      this.$emit("atualizaIndices")
    },


    updateValue(campo, value) {
      if (value == 'true') value = true;
      if (value == 'false') value = false;
      this.update(campo, value);
      this.$emit("change", {
        campo: campo,
        valor: value,
      });
    },
    updateCremacao(value) {
      this.updateCrem(value);
    },

    updateExtras(value) {
      this.updateExtra(value);
    },
    async getAdicionalPlano() {
      let codPlano = 0;
      //OBTEM PLANO
      if (this.$route.query.plano == 'Adapt') {
        codPlano = 17
      }
      if (this.$route.query.plano == 'Essencial') {
        codPlano = 13
      }
      if (this.$route.query.plano == 'Clássico') {
        codPlano = 14
      }
      if (this.$route.query.plano == 'Supremo') {
        codPlano = 15
      }

      let pform = new FormData();

      pform.append("app", "getadicional");
      pform.append("cod", codPlano);

      await this.$axios.post(this.url, pform, {
        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      }).then((response) => this.valAdicional = response.data);

      if (typeof this.valAdicional == 'number')
        this.valAdicional = this.formatPrice(this.valAdicional);

      this.updateExtras(this.valAdicional);
    },

    clearIdade() {
      this.maiorIdade = 'n';
      this.updateValue('maiorIdade', 'n')
    },
    async getCremacao() {
      let crData = new FormData();
      crData.append("app", "getcremacao");
      let response = await this.$axios.post(this.url, crData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      });

      this.valCremacao = this.formatPrice(response.data)

      this.updateCremacao(this.valCremacao);

    }
  },

  data() {
    return {
      maiorIdade: 'n',
      crematorio: 'n',
      conjuge: false,
      seguro: 'n',
      filhos: 0,
      dpai: false,
      dmae: false,
      dsogro: false,
      dsogra: false,
      valAdicional: 0,
      valCremacao: 0,

    }
  },

  mounted() {
    this.getAdicionalPlano();
    this.getCremacao();
  }


}
</script>

<style scoped></style>
