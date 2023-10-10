<template>
  <div>

    <nav class="navbar" style="background-color: #e6e6e6; border-bottom: 6px solid #636aa4;">
      <div id="" class="navbar-menu">
        <div class="navbar-start">
          <div class="container">
            <h1 v-if="getRoute" class="title is-2 has-text-centered mt-6">Contrate seu plano -
              {{ this.$route.query.plano }}</h1>
          </div>

        </div>

      </div>
      <div class="navbar-brand">

        <img class="mt-4 mr-4" src="https://www.athia.com.br/wp-content/themes/athia_theme/images/logo-athia.png">

      </div><!-- .navbar-brand -->
    </nav>

    <section class="main-content columns">
      <div class="container column is-10"> <br><br><br>
        <Nuxt />
      </div>
    </section>
  </div>
</template>

<script>
export default {
  name: 'DefaultLayout',
  data() {
    return {
      items: [
        {
          title: 'Home',
          icon: 'home',
          to: { name: 'index' }
        },
        {
          title: 'Contratar',
          icon: 'lightbulb',
          to: { name: 'contratar' }
        }
      ],
      plano: ''
    }
  },
  methods: {

    getRoute() {
      return this.$route.fullPath != "/";
    }

  }
}
</script>

<style>
.panel-heading {
  margin-bottom: 0 !important;
  padding: 0.4em 1em !important;
}
.box{
  padding-top: 0;
}
</style>

<style scoped>.navbar-burger.right {
  margin-right: auto;
  margin-left: 0;
}

.logoathia {
  position: relative;
  padding-right: 80px;
}

nav.navbar {
  /* height: 6rem !important;*/
}

element {
  background-color: #e6e6e6;
  border-bottom: 6px solid #636aa4;
}

.pt-3 {
  padding-top: 1rem !important;
}

.row {
  display: -ms-flexbox;
  display: flex;
  -ms-flex-wrap: wrap;
  flex-wrap: wrap;
  margin-right: -15px;
  margin-left: -15px;
}

*,
::after,
::before {
  box-sizing: inherit;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.5;
  color: #212529;
}

.pl-5 {
  padding-left: 1.5rem !important;
}

.pt-5 {
  padding-top: 1.5rem !important;
}


.rounded {
  border-radius: 30px;
}

.logoathia {
  max-width: 195px;

  height: auto;
}

img {
  vertical-align: middle;
  border-style: none;
}

*,
::after,
::before {
  box-sizing: inherit;
}

.text-center {
  text-align: center !important;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.5;
  color: #212529;
}

.h1,
h1 {
  font-size: 2.5rem;
}


@font-face {
  font-family: "Gilroy Regular";
  src: url("http://db.onlinewebfonts.com/t/1dc8ecd8056a5ea7aa7de1db42b5b639.eot");
  /* IE9*/
  src: url("http://db.onlinewebfonts.com/t/1dc8ecd8056a5ea7aa7de1db42b5b639.eot?#iefix") format("embedded-opentype"),
    /* IE6-IE8 */
    url("http://db.onlinewebfonts.com/t/1dc8ecd8056a5ea7aa7de1db42b5b639.woff2") format("woff2"),
    /* chrome firefox */
    url("http://db.onlinewebfonts.com/t/1dc8ecd8056a5ea7aa7de1db42b5b639.woff") format("woff"),
    /* chrome firefox */
    url("http://db.onlinewebfonts.com/t/1dc8ecd8056a5ea7aa7de1db42b5b639.ttf") format("truetype"),
    /* chrome firefox opera Safari, Android, iOS 4.2+*/
    url("http://db.onlinewebfonts.com/t/1dc8ecd8056a5ea7aa7de1db42b5b639.svg#Gilroy") format("svg");
  /* iOS 4.1- */
}

body {
  /*font-family: 'Gilroy Regular', sans-serif;*/
}

main {
  padding: 0 0 0 0;
}

.title-page {
  margin: 0 0 0 0;
}

.title-page h1 {
  font-family: 'Gilroy Regular', sans-serif;
  font-size: 38px;
  /*line-height: 46px;*/
  margin: 0;
  color: #FFF;
  font-weight: bold;
}

.envie h1 {
  font-family: 'Gilroy Regular', sans-serif;
  font-size: 20px;
  /*line-height: 46px;*/
  margin: 0;
  color: #636aa4;
  font-weight: 800;
}

.title-page span {
  color: #FFF;
  font-style: italic;
}

.title-form h2 {
  margin: 0;
  color: #666;
  font-size: 18px;
  line-height: 32px;
  font-family: 'Gilroy Regular', sans-serif;
  font-weight: 600;
}

form {
  margin: 20px 0 20px 0;
}

form label {
  margin-bottom: 0;
}

form .form-group .form-control {
  height: 40px;
  padding: 3px 10px;
  width: 100%;
  font-family: 'Gilroy Regular', sans-serif;
  font-size: 16px;
}

.form-inline .form-group {
  padding: 0;
}

form .form-group .form-control::-webkit-input-placeholder {
  color: #aaaaaa;
  font-weight: normal;
  font-style: italic;
}

form .form-group .form-control::-moz-input-placeholder {
  color: #aaaaaa;
  font-weight: normal;
  font-style: italic;
}

form .form-group .form-control:-ms-input-placeholder {
  color: #aaaaaa;
  font-weight: normal;
  font-style: italic;
}

form .form-group .form-control:-moz-input-placeholder {
  color: #aaaaaa;
  font-weight: normal;
  font-style: italic;
}

form .form-group .btnMy {
  background: #636aa4;
  color: #ffffff;
  border-radius: 3px;
  padding: 7px;
}

form .form-group .btnMy i {
  font-size: 18px;
}

form .form-group .btnMy:hover {
  background: #494B71;
  cursor: pointer;
}

.dataFalecimento {
  max-width: 100%;
  color: #ffffff;
  background: #382c47;
  margin-top: 10px;
  padding-left: 15px;
  padding-top: 5px;
  font-family: 'Khula', sans-serif;
  font-weight: 600;
  font-size: 18px;
  border-radius: 25px;
}

.tabela-pesquisa {
  /*max-width: 910px;*/
}

#accordion {
  width: 100%;
}

#accordion .card {
  border-color: transparent;
  padding: 0 0.5rem;
}

#accordion .card .card-header {
  margin-top: 10px;
  background-color: #f5f5f5;
  padding: 0 0.8rem;
  border-radius: 15px;
  min-height: 125px;
}

#accordion .card .card-header .myA {
  font-family: 'Khula', sans-serif;
  font-size: 20px;
  color: #382c47;
  font-weight: 700;
}

#accordion .card .card-header a.aa {
  color: #aaa;
  font-size: 14px;
}

#accordion .card .card-header a.aa span {
  color: #636aa4;
  font-weight: 900;
  font-size: 1.1rem;
}

#accordion .card .card-header a:hover {
  text-decoration: none;
}

#accordion .card .collapse {
  background-color: #D6DCE1;
  border-bottom: 2px solid #636aa4;
}

#accordion .card .card-body {
  padding: 0;
  background: #D6DCE1;
}

#accordion .card .card-body .idade {
  background-color: #41437E;
  color: #ffffff;
  max-width: 100%;
  font-size: 0.7rem;
  padding-left: 0.8rem;
  padding-right: 0.8rem;
}

#accordion .card .card-body .idade img {
  vertical-align: baseline;
}

#accordion .card .card-body .idade span {
  color: #636aa4;
}

#accordion .card .card-body .conteudo {
  max-width: 50%;
  width: 50%;
  background-color: #f1f1f1;
  float: left;
  height: 125px;
}

#accordion .card .card-body .conteudo.velorio {
  border-right: 2px solid #636aa4;
}

#accordion .card .card-body .conteudo .titulo {
  background: #B3C2CA;
  color: #41437E;
  font-weight: 700;
  padding: 5px 15px;
  font-size: 15px;
  text-transform: uppercase;
  font-family: 'Khula', sans-serif;
}

#accordion .card .card-body .conteudo .cont {
  font-size: 15px;
  padding: 10px 15px;
  font-weight: 400;
  background-color: #f1f1f1;
  font-family: 'Khula', sans-serif;
  font-weight: 400;
}

#accordion .card .card-body .conteudo .cont a {
  display: flex;
  align-items: center;
  font-size: 9px;
  margin-bottom: 10px;
  color: #636aa4;
  font-weight: bold;
}

#accordion .card .card-body .conteudo .cont a:hover {
  text-decoration: none;
}

#accordion .card .card-body .conteudo .cont a i {
  font-size: 22px;
  margin-right: 10px;
}

#accordion .card .card-body p {
  padding: 0 22px;
  margin: 0;
  font-size: 1.1rem;
}

#accordion .card .card-body ul {
  list-style: none;
  margin-left: 22px;
}

.btnFlores {
  background-color: #ef7d00;
  border: 1px solid #ef7d00;
  color: #FFF;
  border-radius: 30px;
}

.btnFlores:hover {
  background-color: #ef7d00;
  border: 1px solid #ef7d00;
  color: #FFF;
  border-radius: 30px;
}

.title {
  padding-left: 10px;
  background-color: #e5e6dd;
  border-radius: 15px;
  font-weight: bold;
  color: #382c47;
}</style>
