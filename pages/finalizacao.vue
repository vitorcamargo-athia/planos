<template>
  <div>
    <article class="panel is-info">
      <p class="panel-heading">
      </p>
      <div class="box" v-if="!$route.query.vend">
        <h1 class="title has-text-centered has-text-info">Estamos quase lá!</h1>
        <h6 class="title is-4 has-text-centered">Nossa equipe de vendas entrará em contato para validar os dados
          cadastrais e enviar o contrato.
        </h6>
        <h6 class="title is-4 has-text-centered"> Caso precise de ajuda, ligue para (18) 2101-5555 </h6>
      </div>
      <div class="box" v-else>
        <a :href="'/listar-propostas?vend=' + $route.query.vend">
          <BackIcon /> Voltar
        </a>
        <h1 class="title has-text-centered has-text-info">Proposta {{ $route.query.cod_proposta }}</h1>
        <p>
          <strong>Tipo do Plano:</strong> {{ resumo.TIPO_PLANO }}<br />
          <strong>Número do Contrato:</strong> {{ resumo.NRO_CONTRATO }}<br />
          <strong>Nome do Titular:</strong> {{ resumo.NOME_TITULAR }}<br />
          <strong>Telefone do Titular:</strong> <a :href="'tel:' + resumo.TELEFONE">{{ resumo.TELEFONE }}</a><br />
          <strong>E-mail do Titular:</strong> <a :href="'mailto:' + resumo.EMAIL">{{ resumo.EMAIL }}</a><br />
          <strong>Data da Venda:</strong> {{ resumo.DATA_VENDA }}
        </p>
        <h6 class="title is-4">
          <b-field grouped group-multiline position="is-centered">
            <button class="button" @click="pagamento">Associar pagamento de entrada em cartão</button>
            <button class="button" @click="assinatura">Solicitar assinatura</button>
          </b-field>
        </h6>
      </div>
    </article>
  </div>
</template>

<script>
import Swal from 'sweetalert2'
import BackIcon from '~icons/ep/back';
import Url from '~/mixins/Url';

export default {
  name: "finalizacao",
  layout: 'blank',
  components: { BackIcon },
  mixins: [Url],
  async mounted() {
    let fdata = new FormData();

    fdata.append("app", "getresumoproposta");
    fdata.append("cod_proposta", this.$route.query.cod_proposta);

    await this.$axios.post(this.url, fdata, {

      headers: {
        'Content-Type': 'multipart/form-data',
        'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
        'User-Agent': 'My-App',
        'Accept': '*/*',
      }
    }).then((response) => this.resumo = response.data);
  },
  methods: {
    async pagamento() {
      let jaLancado;
      let fdata = new FormData();

      fdata.append("app", "checkpagamento");
      fdata.append("cod_proposta", this.$route.query.cod_proposta);

      await this.$axios.post(this.url, fdata, {

        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      }).then((response) => jaLancado = response.data.toString().trim());

      if (jaLancado == 0) {
        const { value } = await Swal.fire({
          title: 'Insira a autorização',
          input: 'number',
          inputLabel: 'Autorização',
          showCancelButton: true,
          inputValidator: (value) => {
            if (!value) {
              return 'Escreva a autorização!'
            }
          }
        });

        if (value != undefined) {

          let resp;
          let fdata = new FormData();

          fdata.append("app", "setpagamento");
          fdata.append("cod_proposta", this.$route.query.cod_proposta);
          fdata.append("autorizacao", value);

          await this.$axios.post(this.url, fdata, {

            headers: {
              'Content-Type': 'multipart/form-data',
              'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
              'User-Agent': 'My-App',
              'Accept': '*/*',
            }
          }).then((response) => resp = response.data.toString().trim());

          if (resp == 'OK') {
            Swal.fire('Sucesso', 'Autorização atrelada com sucesso!', 'success');
          } else {
            Swal.fire('Erro', 'Erro ao atrelar o pagamento (' + resp + ')', 'error');
          }
        }
      } else {
        Swal.fire('Autorização já lançada!', 'Esse contrato já tem uma autorização atrelada', 'info');
      }
    },
    async assinatura() {
      let r;
      let fdata = new FormData();

      fdata.append("app", "getcoddoc");
      fdata.append("cod_proposta", this.$route.query.cod_proposta);

      await this.$axios.post(this.url, fdata, {

        headers: {
          'Content-Type': 'multipart/form-data',
          'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
          'User-Agent': 'My-App',
          'Accept': '*/*',
        }
      }).then((response) => r = response.data);

      if (r.status == 'A') {
        if (!r.assinado) {
          let opcao = await Swal.fire({
            title: 'Aviso', html: 'Contrato já foi gerado, verifique o seu e-mail! (Você também pode cancelar e o solicitar novamente)', icon: 'info',
            showDenyButton: true, denyButtonText: "Cancelar documento"
          });
          if (opcao.isDenied) {
            let op2 = await Swal.fire({
              title: 'Confirmação', html: 'Deseja mesmo cancelar o documento gerado?', icon: 'question',
              showCancelButton: true, cancelButtonText: "Não", confirmButtonText: "Sim"
            });
            if (op2.isConfirmed) {
              this.$router.push("/assinatura?contrato=" + r.contrato + "&cod_doc=" + r.cod + "&tipo=presential&cod_proposta=" + this.$route.query.cod_proposta + "&vend=" + this.$route.query.vend)
            }
          }
        } else {
          Swal.fire({
            title: 'Aviso', html: 'Contrato já foi assinado pelo cliente!', icon: 'success'
          });
        }
      } else if (r.status == 'N') {
        this.$router.push("/assinatura?contrato=" + r.contrato + "&cod_doc=" + r.cod + "&tipo=presential&cod_proposta=" + this.$route.query.cod_proposta + "&vend=" + this.$route.query.vend)
      } else {
        await Swal.fire({
          title: 'Aviso', html: 'Não há documentos pendentes', icon: 'error'
        });
      }
    }
  }
}
</script>

<style scoped></style>
