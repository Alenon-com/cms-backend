FROM node:18.12-alpine As development

WORKDIR /usr/src/app

COPY package*.json ./
COPY yarn.lock  ./

RUN yarn install --only=development

COPY . .

RUN yarn build
RUN yarn prisma generate

FROM node:12.13-alpine as production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /usr/src/app

COPY package*.json ./
COPY yarn.lock ./

RUN yarn install --only=production

COPY . .

RUN yarn prisma generate
RUN yarn prisma db push

COPY --from=development /usr/src/app/dist ./dist

CMD ["node", "dist/main"]
