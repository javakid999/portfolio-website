import pygame, sys

pygame.init()

ROW_SIZE = 16
FONT_SIZE = 20
SCALE = 3

font = pygame.font.Font('./public/fonts/dogicabold.ttf', FONT_SIZE);
characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 ./*#@'
rows = int(len(characters)/ROW_SIZE)+1
display_resolution = (ROW_SIZE*FONT_SIZE, rows*FONT_SIZE)
window_resolution = (ROW_SIZE*FONT_SIZE*SCALE, rows*FONT_SIZE*SCALE)
display = pygame.Surface(display_resolution)
window = pygame.display.set_mode(window_resolution)

for i in range(len(characters)):
    character = characters[i]
    char_surface = font.render(character, False, (255,255,255))
    display.blit(char_surface, ((i % ROW_SIZE)*FONT_SIZE, int(i / ROW_SIZE) * FONT_SIZE))

pygame.image.save(display, 'tilemap.png')

while True:
    for event in pygame.event.get():
        window.blit(pygame.transform.scale(display, window_resolution), (0,0))
        pygame.display.update();
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()