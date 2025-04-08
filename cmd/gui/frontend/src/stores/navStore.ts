import { ref } from 'vue'
import { defineStore } from 'pinia'

export const useNavStore = defineStore('nav', () => {
  const activePage = ref<string>('projects')

  return { activePage }
})