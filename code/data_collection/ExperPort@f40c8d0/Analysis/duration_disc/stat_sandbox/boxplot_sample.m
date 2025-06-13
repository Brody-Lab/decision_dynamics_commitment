function [] = boxplot_sample

 load carsmall
       boxplot(MPG, Origin)
       boxplot(MPG, Origin, 'sym','r*', 'colors',hsv(7))
       boxplot(MPG, Origin, 'grouporder', ...
                    {'France' 'Germany' 'Italy' 'Japan' 'Sweden' 'USA'})