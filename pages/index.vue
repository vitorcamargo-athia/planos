<template>
  <section class="section" v-if="true">
    <div class="main-content columns box">
      <div class="container column is-5">
        <h1 class="title is-1">Planos Athia</h1>
        <div> - </div>

        <p class="">As melhores soluções em Planos de Benefícios do Oeste Paulista. Atendimento funeral completo, inúmeros benefícios em vida e ampla inclusão de dependentes.
        </p><br> <p>
        Rede de empresas e profissionais conveniados, proporcionando descontos especiais aos clientes Athia o ano todo.
      </p> <br> <p>
        Veja <a href="https://www.athia.com.br/informativo-de-convenios/">informativo de convênios </a> </p> <br> <p>
        Escolha o Plano ideal para a sua família!</p>

      </div>
      <div class="container column">
        <img class="rounded" src="~/assets/img/planos.png"


        ></img>
      </div>
    </div>

    <div class="columns">

      <card
        title="Adapt"
        icon="arrange-bring-to-front"
        price="R$ 29,90"
      >
        <ul>
          <li>Urna Mortuária Padrão</li>
          <li>Sala de Velório Athia </li>
          <li>Transporte de até 200 km por via terrestre contemplando ida e volta</li>
        </ul>
        <br> <br> <br> <br> <br> <br> <br> <br> <br> <br>

      </card>

      <card
        title="Essencial"
        icon="arrange-bring-to-front"
        price="R$ 64,40"
      >

        <ul>
          <li>Sorteio semanal de R$10mil (sujeito à tributação)</li>
          <li>Urna Padrão</li>
          <li>Translado para remoção de até 200km (ida e volta)</li>
          <li>Sala de velório Athia</li>
          <li>Coroa de flores</li>
        </ul>

        <br> <br> <br> <br> <br> <br> <br>
      </card>

      <card
        title="Clássico"
        icon="arrange-bring-to-front"
        price="R$ 88,80"
      >

        <ul>
          <li>Sorteio semanal de R$20mil (sujeito à tributação)</li>
          <li>Seguro de vida de R$2mil</li>
          <li>1 ano de mensalidade grátis (em caso de falecimento do titular)</li>
          <li>1 dependente-cortesia (sem limite de idade)</li>
          <li>Urna Semiluxo</li>
          <li>Translado para remoção de até 500km (ida e volta)</li>
          <li>Sala de velório Athia</li>
          <li>Coroa de flores</li>
        </ul>

      </card>

      <card
        title="Supremo"
        icon="arrange-bring-to-front"
        price="R$ 117,99"
      >

        <ul>
          <li >Sorteio semanal de R$40mil (sujeito à tributação)</li>
          <li >Seguro de vida de R$4mil</li>
          <li>1 ano de mensalidade grátis (em caso de falecimento do titular)</li>
          <li class="list-item">2 dependentes-cortesia (sem limite de idade)</li>
          <li>Urna Luxo</li>
          <li>Translado para remoção de até 1.000km (ida e volta)</li>
          <li>Sala de velório Athia</li>
          <li>Coroa de flores</li>
        </ul>
      </card>
    </div>
  </section>
</template>
<script>
import Card from '~/components/Card'

export default {
  name: 'IndexPage',
  layout : 'blank',
  components: {
    Card
  },
  mounted() {
  //  window.location.href = "https://www.athia.com.br/planos_/";
  },
  created() {

  },
  methods:{
    helloWorld(){

    }
  },
}
</script>

<style scoped>

.rounded{
  border-radius: 30px;
}

p {
  text-indent: 1.5em !important;
  text-align: justify;
}

</style>
