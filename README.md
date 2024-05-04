 ![Fotografia em cores de um drone sobreveando em meio a um céu sem nuvens](/img/header.jpg)
 
 
 O formato de arquivo [ECW](https://en.wikipedia.org/wiki/ECW_(file_format)hexagon ), de propriedade da [Hexagon](https://hexagon.com/), é frequentemente utilizado para a disponibilização de imagens aéreas de alta resolução com tamanho de arquivo reduzido quando comparado a outros populares formatos de imagens georreferenciadas. A licença grátis oferecida pela empresa permite a leitura do arquivo ECW e a conversão para algum outro formato de imagem suportado pelo [GDAL](https://gdal.org/). Já conversão de um arquivo de imagem em algum formato livre para formato ECW requer compra de licença do SDK (Software Development Kit) da Hexagon.

 Enquanto a instalação no Windows é simples, bastando alguns cliques para que o SDK esteja disponível para utilização por linha de comando ou pela interface gráfica do [QGIS](https://www.qgis.org/), em distribuições Linux é necessário fazer o download do SDK e usá-lo na compilação do GDAL com configurações específicas.


Este tutorial é baseado em outro tutorial que criei para instalação local do GDAL, onde mostrava como fazer a compilação em sistemas baseados em Debian/Ubuntu. A instalação local funciona bem, contudo é um processo trabalhoso, demorado e dependente de distribuições específicas. A Hexagon também implementou recentemente algumas restrições para download de seus produtos, o que torna a antiga solução obsoleta.


A conteinerização do ambiente para esta tarefa simples é uma solução mais vantajosa pois o [Docker](https://www.docker.com/) é uma plataforma de conteinerização está disponível para vários sistemas operacionais e o ambiente de desenvolvimento é facilmente reproduzível entre máquinas. Além disso, pessoas não-desenvolvedoras, mas que utilizam alguma distribuição Linux podem usar esta solução para facilitar seus fluxos de trabalho.

**1)** Clone este [repositório](https://github.com/elmoneto/docker-gdal-ecw) para sua máquina.

~~~bash
git clone https://github.com/elmoneto/docker-gdal-ecw
~~~


**2)** Copie o binário de instalação do ECW SDK para a pasta raiz do repositório.

Caso você ainda não o tenha, recomendo criar uma conta na Hexagon e fazer download do SDK por [esta página](https://supportsi.hexagon.com/s/article/ERDAS-ECW-JP2-SDK-Read-Only-Redistributable-download).

**3)** Construa a imagem base para o contêiner:

A imagem foi testada com versões do GDAL acima ou iguais a 3.7 e por padrão está configurada para usar a versão mais recente. Mas você pode escolher a versão que deseja e passá-la ao Dockerfile por meio da flag ```--build-arg```. Verifique o Dockerfile e se estiver de acordo com ele, construa a imagem base para o contêiner com o seguinte comando:

~~~sh
docker build --build-arg="GDAL_VERSION=3.8.5" -t geolinux:gdal-3.8.5-ecw-5.5.0 .
~~~

> A compilação do GDAL demora vários minutos, recomendo que você vá pegar um cafezinho.

**4)** Instancie um novo contêiner utilizando como base a imagem recém-criada e associe uma pasta do seu computador a uma pasta do contêiner para facilitar seu trabalho.

Dessa forma tudo o que você copiar para a pasta da sua máquina está disponível dentro do ambiente conteinerizado e tudo o que você produzir dentro deste ambiente está facilmente disponível para uso na sua máquina. Eu associei, por meio da flag ```-v```, a pasta */home/elmo/ecw* local à pasta */home/ecw* dentro do contêiner, mas você poderia usar outras pastas de sua preferência. A flag ```-it``` acessa o contêiner na pasta definida no WORKDIR do Dockerfile, no nosso caso */home*. Use este comando:

~~~sh
docker run -it -v /home/elmo/ecw:/home/ecw geolinux:gdal-3.8.5-ecw-5.5.0
~~~

> Se quiser que o contêiner seja deletado logo depois que sair do ambiente, é só usar a flag ```-rm```.

**5)** Abra um terminal e teste sua instalação.

Cole esse comando no terminal:

~~~~bash
gdalinfo --formats | grep ECW
~~~~

Se você teve duas linhas de saída mostrando os drivers ECW disponíveis, sua instalação está correta e você pode passar para o próximo passo. :)

**6)** Copie seu arquivo .ecw para a pasta local do seu computador associada ao contêiner. (no meu caso */home/elmo/ecw*)

Agora você pode acessar dentro do contêiner a pasta */home/ecw* e executar o comando [*gdal_translate*](https://gdal.org/programs/gdal_translate.html) para converter o arquivo no formato ECW para seu formato de preferência.

---

Espero ter ajudado e qualquer dúvida é só chamar. :)

---

Referências

- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [@IlliaOvcharenko](https://github.com/IlliaOvcharenko/gdal-docker)
- [@1papaya gist](https://gist.github.com/1papaya/568c4580b1909071696c1cb119101823)

Foto de capa: [Fikri Rasyid](https://unsplash.com/pt-br/@fikrirasyid)