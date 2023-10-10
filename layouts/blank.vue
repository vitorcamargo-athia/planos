<template>
  <div>

    <nav class="navbar" style="background-color: #e6e6e6">
      <div id="" class="navbar-menu">
        <div class="navbar-start">
          <div class="container">

          </div>

        </div>

      </div>
      <div class="navbar-brand">
        <div class="navbar-burger burger right">
          <span></span>
          <span></span>
          <span></span>
        </div>

        <img class="mt-4 mr-4" src="https://www.athia.com.br/wp-content/themes/athia_theme/images/logo-athia.png">

      </div><!-- .navbar-brand -->
    </nav>


    <div class="row pt-3" style="background-color: #e6e6e6; border-bottom: 6px solid #636aa4;">
      <div  v-if="false" class="col-3 text-center pl-4 pb-3 d-block d-sm-none">
        <img src="http://www.athia.com.br/wp-content/uploads/2021/07/logo-athia.png">
      </div>
      <div v-if="false" class="col-9 text-center d-block d-sm-none">
        <h1 class="m-0" style="color: #382c47"> Informe de Falecimento </h1>
      </div>
    </div>



    <section class="main-content columns">
      <div class="container column is-10"> <br><br><br>
        <Nuxt />
      </div>
    </section>
  </div>
</template>

<script>
export default {
  name: "blank"
}
</script>

<style scoped>

</style>
