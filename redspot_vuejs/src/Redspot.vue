<template>
  <div class="Redspot" v-if='redspotIsVisible' id="Redspot">
    <a href="" target="_blank" id="new_tab_link"></a>
    <i class="Redspot__icon">
      <svg xmlns="http://www.w3.org/2000/svg" width="25" height="25" viewBox="0 0 25 25">
        <g fill="none" fill-rule="evenodd">
          <path d="M-4-4h34v34H-4z"/>
          <path fill="#FFF" id="zoom" fill-rule="nonzero" d="M17.958 15.833H16.84l-.396-.382a9.168 9.168 0 0 0 2.224-5.993A9.208 9.208 0 0 0 9.458.25 9.208 9.208 0 0 0 .25 9.458a9.208 9.208 0 0 0 9.208 9.209c2.281 0 4.378-.836 5.993-2.225l.382.397v1.12l7.084 7.069 2.11-2.111-7.069-7.084zm-8.5 0a6.366 6.366 0 0 1-6.375-6.375 6.366 6.366 0 0 1 6.375-6.375 6.366 6.366 0 0 1 6.375 6.375 6.366 6.366 0 0 1-6.375 6.375z"/>
        </g>
      </svg>
    </i>
    <div class="Redspot__actionLabel">{{ currentLabel }}</div>
    <transition name="tip" mode="out-in">
      <div class="Redspot__tips" v-if="currentTip !== ''">
        <a :href="newProjectLink" class="Redspot__tip Redspot__tip--project">Create project</a>
        <!-- <a href="#" class="Redspot__tip Redspot__tip--search">New search</a> -->
      </div>
    </transition>
    <input
      type="text"
      placeholder="Recherche Redspot"
      class="Redspot__input"
      id="Redspot__input"
      v-model="inputText"
      ref="input"
      v-focus
      @keydown.up.prevent.stop="focusUp"
      @keydown.down.prevent.stop="focusDown"
      @keydown.enter.prevent.stop="goto"
      @keyup="updateCurrentIndex"
      >
    <transition name="result" mode="out-in">
      <div class="Redspot__results" v-if="currentProject">
        <div class="Redspot__resultList">
          <transition-group name="list" tag="p">
            <a v-for="p in filteredProject"
              class="Redspot__project"
              tabindex="-1"
              :class="{'Redspot__project--focused': p.focused}"
              :key="p.name"
              :href="p.url"
              @mouseenter="updateCurrentIndex"
              @click.prevent="goto">
              {{ p.name }}
            </a>
          </transition-group>
        </div>
        <div class="Redspot__help">
          <pre class="Redspot__shortDoc">
#123   : Issue #123
pri    : Projet Pridami
! foo  : Search for foo
/a     : Page des Activités
/w ffe : Wiki - FFEPGV
          </pre>
          <a class="Redspot__docLink" href="https://support.synbioz.com/projects/redmine-synbioz/wiki/Redspot" target="_blank">Documentation</a>
        </div>
      </div>
    </transition>
  </div>
</template>

<script>
  import Vue from 'vue'
  import diacritics from 'diacritics'
  import Fuse from 'fuse.js'

  export default {
    name: 'Redspot',
    data: function () {
      return {
        redspotIsVisible: false,
        inputText: '',
        commands: [
          {
            title: 'Activité',
            alias: ['/a', '/activity'],
            url: '/activity'
          }, {
            title: 'Roadmap',
            alias: ['/r', '/roadmap'],
            url: '/roadmap'
          }, {
            title: 'Demandes',
            alias: ['/#', '/i', '/issues'],
            url: '/issues'
          }, {
            title: 'Nouvelle demande',
            alias: ['/+', '/n', '/new'],
            url: '/issues/new'
          }, {
            title: 'Gantt',
            alias: ['/g', '/gantt'],
            url: '/issues/gantt'
          }, {
            title: 'Calendar',
            alias: ['/c', '/calendar'],
            url: '/issues/calendar'
          }, {
            title: 'Annonces',
            alias: ['/n', '/news'],
            url: '/news'
          }, {
            title: 'Documents',
            alias: ['/d', '/documents'],
            url: '/documents'
          }, {
            title: 'Wiki',
            alias: ['/w', '/wiki'],
            url: '/wiki'
          }, {
            title: 'Wiki by date',
            alias: ['/wd'],
            url: '/wiki/date_index'
          }, {
            title: 'Wiki by title',
            alias: ['/wt'],
            url: '/wiki/index'
          }, {
            title: 'Files',
            alias: ['/f', '/files'],
            url: '/files'
          }, {
            title: 'Configuration',
            alias: ['/s', '/settings'],
            url: '/settings'
          }
        ],
        aliases: null,
        currentIndex: 0,
        currentTip: '',
        fuseProjectList: null,
        fuse_options: {
          include: ['score'],
          shouldSort: true,
          tokenize: true,
          matchAllTokens: true,
          threshold: 0.1,
          location: 0,
          distance: 1000,
          maxPatternLength: 32,
          minMatchCharLength: 2,
          keys: ['name']
        }
      }
    },
    methods: {
      inputCommand: function () {
        var a = this.inputText.split(' ').filter(word => word[0] === '/').pop()
        return this.aliases[a] ? this.aliases[a] : ''
      },
      inputProject: function () {
        var p = this.inputText.split(' ').filter(word =>
          word[0] !== '/' && word[0] !== '!' && word[0] !== '#'
        ).join(' ')
        p = p.replace(/\s*$/, '')
        return p.length ? p : ''
      },
      updateCurrentIndex: function (e) {
        if (this.filteredProject.length > 0) {
          if (e && e.type === 'mouseenter') {
            this.currentIndex = Array.prototype.indexOf.call(e.currentTarget.parentNode.childNodes, e.currentTarget)
          }
          this.filteredProject.forEach(function (p) {
            p.focused = false
          })
          this.filteredProject[this.currentIndex].focused = true
        }
      },
      focusUp: function () {
        this.currentIndex--
        if (this.currentIndex < 0) {
          this.currentIndex = 0
        }
        this.updateCurrentIndex()
      },
      focusDown: function () {
        this.currentIndex++
        if (this.filteredProject && this.currentIndex >= this.filteredProject.length - 1) {
          this.currentIndex = this.filteredProject.length - 1
        }
        this.updateCurrentIndex()
      },
      toggleRedspot: function () {
        this.redspotIsVisible = !this.redspotIsVisible
      },
      goto: function (e) {
        let url = ''

        if (this.currentProject) {
          url += this.currentProject.url
        } else {
          url += this.parsed.issue ? '/issues/' + this.parsed.issue : ''
          url += this.parsed.search ? '/search?utf8=✓&q=' + this.parsed.search : ''
        }
        url += this.parsed.command ? this.parsed.command.url : ''

        if (url) {
          url = window.location.origin + url
          if (e.metaKey) {
            window.open(url, '_blank')
          } else {
            window.location = url
          }
        }
      }
    },
    computed: {
      parsed: function () {
        if (this.inputText.length > 0) {
          return {
            issue: this.inputText.split('').shift() === '#' ? this.inputText.split('#').pop() : '',
            search: this.inputText.split('').shift() === '!' ? this.inputText.replace('!', '') : '',
            command: this.inputCommand(),
            project: this.inputProject()
          }
        } else {
          return {
            issue: '',
            search: '',
            command: '',
            project: ''
          }
        }
      },
      newProjectLink: function () {
        return `/projects/new?project[name]=${this.inputText}`
      },
      currentLabel: function () {
        var l = ''
        l += this.parsed.search ? `Search : ${this.parsed.search}` : ''
        l += this.parsed.issue ? `Issue ${this.parsed.issue}` : ''
        l += this.parsed.command ? this.parsed.command.title : ''
        l += this.parsed.command && this.currentProject ? ' - ' : ''
        l += this.currentProject ? this.currentProject.name : ''

        if (l.length > 0) {
          this.currentTip = ''
        } else {
          let p = this.parsed.project
          this.currentTip = p && p.length >= 3 ? p : ''
        }
        return l.length ? l : null
      },
      filteredProject: function () {
        return this.parsed.project ? this.fuseProjectList.search(this.parsed.project) : []
      },
      currentProject: function () {
        return this.filteredProject ? this.filteredProject[this.currentIndex] : null
      }
    },
    directives: {
      focus: function (el) {
        Vue.nextTick(function () {
          el.focus()
        })
      }
    },
    mounted: function () {
      // On ESC => open Redspot
      var that = this
      document.addEventListener('keyup', function (e) {
        if (e.keyCode === 27) {
          that.toggleRedspot()
        }
      })
    },
    created: function () {
      // Init aliases
      this.aliases = this.commands.reduce(function (curAliases, command) {
        command.alias.forEach(function (alias) {
          curAliases[alias] = command
        })
        return curAliases
      }, {})

      // Init Project List
      if (document.getElementById('project_quick_jump_box').length !== 0) {
        var projectList = []
        document.querySelectorAll('#project_quick_jump_box option').forEach(function (opt) {
          var str = opt.value.match(/\/projects\/(.*)\?.*/)
          if (str !== null) {
            projectList.push({
              name: diacritics.remove(opt.innerText.split('»').pop().trim()),
              url: opt.value.split('?').shift(),
              focused: false
            })
          }
        })
        this.fuseProjectList = new Fuse(projectList, this.fuse_options)
      } else {
        console.error("Can't create the project list")
      }
    }
  }
</script>

<style lang="sass" >

  // Synbioz Thème
  $background-color: rgb(42,48,56)
  $primary-color: #4ca5d1
  $secondary-color: #4ca5d1

  $text-color: #fff
  $link-color: $primary-color
  $icon-color: rgba($text-color, 0.5)
  $focus-background: $primary-color
  $focus-color: $text-color
  $help-background: rgba($background-color,0.5)
  $result-background: rgba($background-color,0.1)
  $border: 0
  $border-radius: 5px
  $box-shadow: 0 2em 4em 0 rgba(0,0,0,0.3)

  $font-family: -apple-system, BlinkMacSystemFont, sans-serif
  $help-font-family: monospace
  $font-size: 16px
  @import "~SASS/style.sass"
</style>
