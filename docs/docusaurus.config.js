// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require("prism-react-renderer/themes/github");
const darkCodeTheme = require("prism-react-renderer/themes/dracula");

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: "Cruky",
  tagline: "Cruky is fast and easy library for creating APIs",
  url: "https://seifalmotaz.github.io/",
  baseUrl: "/",
  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "warn",
  favicon: "img/favicon.ico",
  organizationName: "seifalmotaz", // Usually your GitHub org/user name.
  projectName: "cruky", // Usually your repo name.
  presets: [
    [
      "classic",
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve("./sidebars.js"),
          // Please change this to your repo.
          // editUrl:
          //   "https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/",
        },
        blog: false,
        // blog: {
        //   showReadingTime: true,
        //   // Please change this to your repo.
        //   editUrl:
        //     "https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/",
        // },
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        title: "Cruky docs",
        logo: {
          alt: "Cruky docs",
          src: "img/logo.svg",
        },
        items: [
          {
            type: "doc",
            docId: "intro",
            position: "left",
            label: "Tutorial",
          },
          // { to: "/blog", label: "Blog", position: "left" },
          {
            href: "https://github.com/seifalmotaz/cruky",
            label: "GitHub",
            position: "right",
          },
          {
            href: "https://pub.dev/packages/cruky",
            label: "Pub",
            position: "right",
          },
          {
            href: "https://pub.dev/documentation/cruky/latest/",
            label: "API reference",
            position: "right",
          },
        ],
      },
      footer: {
        style: "dark",
        links: [
          {
            title: "Docs",
            items: [
              {
                label: "Tutorial",
                to: "/docs/intro",
              },
            ],
          },
          {
            title: "Package URLs",
            items: [
              {
                label: "GitHub",
                href: "https://github.com/seifalmotaz/cruky",
              },
              {
                href: "https://pub.dev/packages/cruky",
                label: "Pub",
              },
              {
                href: "https://pub.dev/documentation/cruky/latest/",
                label: "API reference",
              },
            ],
          },
          {
            title: "More",
            items: [
              {
                label: "Blog",
                to: "/blog",
              },
              {
                label: "GitHub",
                href: "https://github.com/facebook/docusaurus",
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Cruky, Inc. Built with Docusaurus.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
        additionalLanguages: ["dart"],
      },
    }),
};

module.exports = config;
