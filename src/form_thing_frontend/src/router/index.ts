import { createRouter, createWebHistory, START_LOCATION } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { nextTick } from 'vue'
import { useFormStore } from '@/stores/formStore'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      component: () => import('@/views/MainView.vue'),
      children: [
        {
          path: '/',
          name: 'home',
          component: () => import('@/components/HomePage.vue')
        },
        {
          path: '/login',
          name: 'login',
          component: () => import('@/components/LoginPage.vue')
        }
      ]
    },
    {
      path: '/admin',
      component: () => import('@/views/AdminView.vue'),
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'admin',
          component: () => import('@/components/AdminFormsPage.vue'),
          meta: { title: 'Forms' }
        },
        {
          path: 'form/:formId',
          name: 'adminFormSingle',
          component: () => import('@/components/AdminFormSinglePage.vue'),
          meta: { title: 'Form Details' }
        }
      ]
    },
    {
      path: '/forms/',
      component: () => import('@/views/MainView.vue'),
      children: [
        {
          path: ':formId',
          name: 'formSingle',
          component: () => import('@/components/PublicFormPage.vue')
        }
      ]
    },
    // otherwise redirect to home
    { path: '/:pathMatch(.*)*', name: 'NotFound', redirect: { name: 'home' } }
  ]
})

// Check if the route requires authentication
router.beforeEach(async (to, from) => {
  const authStore = useAuthStore()
  // first try to login
  if (from === START_LOCATION) {
    await authStore.login_retry()
  }
  // check if the route requires authentication
  if (to.matched.some((record) => record.meta.requiresAuth)) {
    // check if the user is logged in
    if (!(await authStore.isAuthenticated())) {
      // redirect to login page
      return { name: 'login' }
    }
  }
})

// Change title meta for AdminFormSinglePage
// router.beforeEach(async (to) => {
//   if (to.name !== 'adminFormSingle') return

//   // get the form id
//   const formId = to.params.formId as string
//   // get the form
//   const form = await useFormStore().getFormById(formId)
//   // set the title
//   if (form) {
//     to.meta.title = form.name
//     return
//   }
// })

// Focus the body on route change
router.afterEach((from, to) => {
  if (from.path !== to.path) {
    nextTick(() => {
      document.body.tabIndex = 0
      document.body.focus()
      document.body.tabIndex = -1
    })
  }
})

export default router
